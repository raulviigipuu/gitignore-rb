#!/usr/bin/env ruby

require 'pathname'
require 'open3'

def git_repo_root(path)
  max_depth = 100
  depth = 0

  while depth < max_depth
    return path if File.directory?(File.join(path, '.git'))
    parent = File.expand_path('..', path)
    break if parent == path # Reached the root of the filesystem
    path = parent
    depth += 1
  end

  nil
end

def git_installed?
  _stdout, _stderr, status = Open3.capture3('git --version')
  status.success?
end

def path_ignored?(repo_root, path)
  relative_path = Pathname.new(path).relative_path_from(Pathname.new(repo_root)).to_s
  _stdout, _stderr, status = Open3.capture3('git', 'check-ignore', '-q', relative_path, chdir: repo_root)
  status.success?
end

# Main
if ARGV.length != 1
  puts '😢 Please provide a path. Usage: ./gitignore.rb /path/to/file'
  exit 1
end

path = File.expand_path(ARGV[0])

unless git_installed?
  puts '😢 Git is not installed or not in the system PATH.'
  exit 1
end

repo_root = git_repo_root(path)

unless repo_root
  puts '🔍 The provided path is not part of a Git repository.'
  exit 1
end

if path_ignored?(repo_root, path)
  puts '🚫 The provided path is ignored by Git.'
else
  puts '✅ The provided path is not ignored by Git.'
end
