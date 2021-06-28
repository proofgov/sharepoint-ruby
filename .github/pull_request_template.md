[EV-XXXXX](https://proof-tech.atlassian.net/browse/EV-XXXXX)

### Overview

Please include a summary of the changes in this pull request.
List any dependencies that are required before this change is applied.

### Solution

How did you solve the problem?
Call out any particular implementation choices or design decisions you made

### Screenshots

[insert screenshots here]

### Testing Instructions

Describe, for your colleagues, how they can test your code locally on their system

### Pre-Merge Checklist

- [ ] My changes generate no new warnings / errors in the console
- [ ] I have written/updated Ruby/JS tests for the areas of the code base that I have modified
- [ ] I have done end-to-end QA testing of sections of the application I have altered
- [ ] I am prepared for this code to go to production today (or there is a WIP label on the pull request)
- [ ] I have translated new / edited user facing text (or have a separate ticket for i18N)
- [ ] [_OPTIONAL_] I have considered the effects of my code on data integrity
- [ ] [_OPTIONAL_] I have demoed the code and gotten a review from a member of the CS team (for customer facing code)

### Special Pre- or Post-Deployment Instructions

List any changes (if any) that need to happen in production around the deploy of this code. e.g.

1. any commands to run on the host
2. any environment variables that need to be added (share via keeper! Not here!)
3. any commands to be run in rails console

If deploying a new version:
1. Build your new version (in bash console).
   `gem build proof-sharepoint-ruby.gemspec`
2. Publish the gem (in bash)
   `gem push proof-sharepoint-ruby-x.x.x.gem`
   > delete the *.gem file afterwards.

Reminder that deploy instructions are [here](https://github.com/proofgov/proofgov/wiki/Devops-Deploy-steps)
