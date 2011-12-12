require 'spec_helper'

describe "The cuukie_server command" do
  it "starts the Cuukie server on port 4569 by default" do
    start_process "ruby bin/cuukie_server >/dev/null 2>&1"
    wait_for_server_on_port 4569
    stop_server_on_port 4569
  end

  it "starts the Cuukie server on any given port" do
    start_process "ruby bin/cuukie_server 4570 >/dev/null 2>&1"
    wait_for_server_on_port 4570
    stop_server_on_port 4570
  end
end

require 'tempfile'

describe "The cuukie formatter" do
  before :each do
    @out = Tempfile.new('cuukie.tmp')
  end

  after :each do
    @out.delete
  end
  
  it "expects a server on localhost:4569 by default" do
    begin
      start_process "ruby bin/cuukie_server 4569 >/dev/null 2>&1"
      wait_for_server_on_port 4569
      cmd = "cd spec/test_project && \
             cucumber features/1_show_scenarios.feature:9 \
                      --format cuukie >#{@out.path}"
      system(cmd).should be_true
      @out.read.should == ''
    ensure
      stop_server_on_port 4569
    end
  end

  it "can point to a different server" do
    start_process "ruby bin/cuukie_server 4570 >/dev/null 2>&1"
    begin
      wait_for_server_on_port 4570
      cmd = "cd spec/test_project && \
             cucumber features/1_show_scenarios.feature:9 \
                      CUUKIE_SERVER=http://localhost:4570 \
                      --format cuukie >#{@out.path}"
      system(cmd).should be_true
      @out.read.should == ''
    ensure
      stop_server_on_port 4570
    end
  end
  
  it "fails gracefully if the server is down" do
    cmd = "cd spec/test_project && \
           cucumber features/1_show_scenarios.feature:9 \
                    CUUKIE_SERVER=http://some.server:4570 \
                    --format cuukie >#{@out.path}"
    system(cmd).should be_true
    @out.read.should match 'I cannot find the cuukie_server on http://some.server:4570'
  end
end

describe "The cuukie command" do
  before(:each) { @out = Tempfile.new('cuukie.tmp') }
  after(:each) { @out.delete }

  it "shows help with -h" do
    system "ruby bin/cuukie --help >#{@out.path}"
    @out.read.should match /Usage: cuukie \[options\]/
  end

  it "starts the server and runs cucumber with the cuukie formatter" do
    system "ruby bin/cuukie spec/test_project/features/ \
                            --require spec/test_project/features/step_definitions/ \
                            --require lib/cuukie \
                            --no-wait \
                            --leave_server_open \
                            >#{@out.path}"

    @out.read.should match 'All features checked'
    html.should match "Passing Scenario"
    stop_server_on_port '4569'
  end
  
  it "gives instructions to access the page if --showpage is not enabled" do
    system "ruby bin/cuukie spec/test_project/features/ \
                            --require spec/test_project/features/step_definitions/ \
                            --require lib/cuukie \
                            --no-wait \
                            >#{@out.path}"
    
    @out.read.should match 'View your features at http://localhost:4569'
  end

  it "closes the server on exit" do
    system "ruby bin/cuukie spec/test_project/features/ \
                            --require spec/test_project/features/step_definitions/ \
                            --require lib/cuukie \
                            --no-wait \
                            >/dev/null 2>&1"
    
    lambda { GET '/' }.should raise_error
  end
end
