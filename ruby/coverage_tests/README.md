## Ruby Coverege Tests

#### To run the tests successfully we required few tools (instruction for the installation could be found on the tools websites)
1. ruby  https://www.ruby-lang.org/en/
2. node js https://nodejs.org/en/
3. yarn https://yarnpkg.com/
4. docker https://www.docker.com/get-started

####Steps to run the tests for the first time
1. run command `yarn install` // install JS dependencies
2. open ruby directory
3. run command `bundle install` // install ruby dependencies
4. run command `yarn ruby` // command which generates and run tests, send report if all the tests passed, start docker selenium container before execution and delete it's after tests run

#### There command to run tests on the CI `yarn ruby:ci` 
#### There command to run tests and send report to the prod instead of the sandbox `yarn ruby:prod`

#### Note running tests requires selenium server to be started(Could be done from the cli `yarn docker:start`, `yarn docker:stop`).
#### List of the command which can be used (They are used during execution of the command above).
1. `yarn ruby:create` // Command only generates new tests
2. `yarn ruby:run` // Command run the tests in 1 thread, can be used for the debugging separate tests
3. `yarn ruby:run:parallel` // Command run all the tests using 10 threads
4. `yarn ruby:report:merge` // Command to merge reports from all threads into single one ./ruby/coverage-test-report.xml file
5. `yarn ruby:report` // Command process ./ruby/coverage-test-report.xml report and send it to the sandbox dashboard
6. `yarn ruby:report:prod` // Command process ./ruby/coverage-test-report.xml report and send it to the prod dashboard
7. `yarn ruby:test` // Command which generates tests, execute them in parallel and send report to sandbox dashboard
8. `yarn ruby:test:prod` `yarn ruby:test` // Command which generates tests, execute them in parallel and send report to prod dashboard

 
####If the dependencies haven't changed to generate and run the tests only the last step needed

<