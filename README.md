# Capistrano Voupe

Capistrano scripts/configs for use in Voupe applications.

## Installation

Add this to the development group in the Gemfile.

	gem "capistrano-voupe", :git => "git@codebasehq.com:voupe/tools-utilities/capistrano-voupe.git"


## Usage

In `config/deploy.rb` add the required files.


### Assets

	require "capistrano-voupe/assets"

### Rails Config

	require "capistrano-voupe/rails_config"

### Delayed Job

	require "capistrano-voupe/delayed_job"