#!/usr/bin/env ruby
# frozen_string_literal: true

require "net/http"
require "json"
require "fileutils"
require "base64"
require "optparse"
require "rbnacl"
require "uri"

GITHUB_API_URL = "https://api.github.com"
PRIVATE_KEY_PATH = File.expand_path("~/Dropbox/Personal/secrets/pull-request-auto-merging-bot.private-key.pem", __dir__)

def github_request(method, path, body = nil)
  uri = URI.parse("#{GITHUB_API_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = case method
            when :get then Net::HTTP::Get.new(uri.path)
            when :post then Net::HTTP::Post.new(uri.path)
            when :put then Net::HTTP::Put.new(uri.path)
            else raise "Unsupported HTTP method: #{method}"
            end

  request["Authorization"] = "Bearer #{ENV["GITHUB_TOKEN"]}"
  request["Accept"] = "application/vnd.github.v3+json"
  request.content_type = "application/json"
  request.body = body.to_json if body

  response = http.request(request)

  # Return response code and parsed body if response has content
  parsed_body = JSON.parse(response.body) if response.body && !response.body.empty?
  [response.code.to_i, parsed_body]
end

def set_action_variable(repo_name, name, value)
  path = "/repos/#{repo_name}/actions/variables"
  body = { name: name, value: value }

  status_code, response = github_request(:post, path, body)

  if status_code == 409
    # Variable already exists, update it
    puts "Variable #{name} already exists, updating..."
    github_request(:put, "#{path}/#{name}", body)
  elsif status_code >= 400
    raise "Failed to set variable #{name}: #{response["message"] if response}"
  end

  response
end

# Secret encryption related functions
def get_public_key(repo_name, type)
  path = "/repos/#{repo_name}/#{type}/secrets/public-key"
  status_code, response = github_request(:get, path)

  if status_code >= 400
    raise "Failed to get public key: #{response["message"] if response}"
  end

  [response["key_id"], response["key"]]
end

def encrypt_secret(value, public_key)
  public_key_bytes = Base64.decode64(public_key)
  box = RbNaCl::Boxes::Sealed.from_public_key(public_key_bytes)
  encrypted_value = box.encrypt(value)
  Base64.strict_encode64(encrypted_value)
end

def set_secret(repo_name, type, name, value)
  # Get public key for secret encryption
  key_id, public_key = get_public_key(repo_name, type)

  # Encrypt secret value with public key
  encrypted_value = encrypt_secret(value, public_key)

  # Set encrypted secret
  path = "/repos/#{repo_name}/#{type}/secrets/#{name}"
  body = {
    encrypted_value: encrypted_value,
    key_id: key_id
  }

  status_code, response = github_request(:put, path, body)
  if status_code >= 400
    raise "Failed to set secret #{name}: #{response["message"] if response}"
  end

  response
end

def set_action_secret(repo_name, name, value)
  set_secret(repo_name, "actions", name, value)
end

def set_dependabot_secret(repo_name, name, value)
  set_secret(repo_name, "dependabot", name, value)
end

# Main execution related functions
def print_github_token_error
  puts "\e[31mError: GITHUB_TOKEN environment variable is not set.\e[0m"
  puts "GITHUB_TOKEN is required to use the GitHub API."
  puts "Please follow these steps:"
  puts "1. Generate a GitHub Personal Access Token at:"
  puts "   https://github.com/settings/personal-access-tokens"
  puts "2. Set the environment variable: export GITHUB_TOKEN='your-token'"
  exit 1
end

def parse_repo_from_url(url)
  uri = URI.parse(url)
  return nil unless uri.host == "github.com"

  # Extract owner and repo from path
  # Handles the following formats:
  # - https://github.com/owner/repo
  # - https://github.com/owner/repo.git
  path_parts = uri.path.split("/").reject(&:empty?)
  return nil unless path_parts.size >= 2

  owner = path_parts[0]
  repo = path_parts[1].sub(/\.git$/, "")
  "#{owner}/#{repo}"
end

def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} OWNER/REPO or REPOSITORY_URL"
    opts.separator ""
    opts.separator "Examples:"
    opts.separator "  #{$PROGRAM_NAME} octocat/Hello-World"
    opts.separator "  #{$PROGRAM_NAME} https://github.com/octocat/Hello-World"
    opts.separator "  #{$PROGRAM_NAME} https://github.com/octocat/Hello-World.git"
    opts.separator ""
    opts.separator "Options:"

    opts.on("-h", "--help", "Show this help message") do
      puts opts
      exit
    end
  end.parse!

  if ARGV.empty?
    puts "Error: Repository name or URL is not specified"
    puts "Usage: #{$PROGRAM_NAME} OWNER/REPO or REPOSITORY_URL"
    exit 1
  end

  input = ARGV[0]
  repo_name = if input.include?("://")
                # Input is a URL
                parsed = parse_repo_from_url(input)
                unless parsed
                  puts "Error: Invalid GitHub repository URL"
                  puts "URL must be in the format: https://github.com/owner/repo"
                  exit 1
                end
                parsed
              else
                # Input is owner/repo format
                unless input =~ %r{\A[^/]+/[^/]+\z}
                  puts "Error: Invalid repository name format"
                  puts "Must be in the format: owner/repo"
                  exit 1
                end
                input
              end

  repo_name
end

def validate_requirements(private_key_path)
  unless File.exist?(private_key_path)
    puts "Error: Private key file not found at #{private_key_path}"
    exit 1
  end
end

def main
  # Check environment variable first
  print_github_token_error unless ENV["GITHUB_TOKEN"]

  repo_name = parse_options

  validate_requirements(PRIVATE_KEY_PATH)

  # Set up Actions Variable
  puts "Setting up Actions Variable..."
  set_action_variable(repo_name, "PR_AUTO_MERGER_APP_ID", "1239986")

  # Set up Actions Secret
  puts "Setting up Actions Secret..."
  private_key = File.read(PRIVATE_KEY_PATH)
  set_action_secret(repo_name, "PR_AUTO_MERGER_PRIVATE_KEY", private_key)

  # Set up Dependabot Secret
  puts "Setting up Dependabot Secret..."
  set_dependabot_secret(repo_name, "PR_AUTO_MERGER_PRIVATE_KEY", private_key)

  puts "Setup completed successfully!"
end

main if $PROGRAM_NAME == __FILE__

