---
name: publish-gem
description: Build and publish the ground_control-api gem to RubyGems
user_invocable: true
---

# Publish Gem

Publish a new version of ground_control-api to RubyGems.

## Steps

1. **Verify context**
   - Ensure you're on the `main` branch with a clean working tree
   - Ensure `ground_control-api.gemspec` exists

2. **Extract version**
   - Read version from `lib/ground_control/api/version.rb`
   - Check if this version is already published: `gem info ground_control-api --remote --exact`

3. **Pre-publish checks**
   - Run `bundle exec rubocop` (must pass)
   - Run `bundle exec rspec` (must pass)
   - Verify CHANGELOG.md has an entry for this version

4. **Build**
   - Run `gem build ground_control-api.gemspec`
   - Verify the `.gem` file was created

5. **Publish**
   - Run `gem push ground_control-api-{version}.gem`
   - If OTP is required, ask the user for their MFA code
   - Clean up: `rm ground_control-api-{version}.gem`

6. **Post-publish**
   - Create and push a git tag: `git tag v{version} && git push origin v{version}`
   - Report success with the RubyGems URL
