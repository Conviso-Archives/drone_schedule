#!/usr/bin/ruby
require 'rubygems'
require 'yaml'
require 'rufus/scheduler'

def execute(path,cmd)
 if File.exist?(path)
  result= IO.popen(cmd)
 end
 @ret=result.readlines
end

scheduler = Rufus::Scheduler::PlainScheduler.start_new

file=ARGV[0]
puts file

yml = YAML::load( File.open(file) )

cmd=""
cmd2exe=""
name=""
log=""
date=""
project=""
startdate=""
count=0

yml.keys.sort.each { |x|
 
  if(x==0)
   puts ":::::: Session: #{x} \n" 
   yml[x].each { |key,value|
    puts "#{key} - #{value}"
    case key
     when "Cmd"
      cmd=value
     when "Name"
      name=value
     when "Project_id"
      project=value
     when "Start_date"
      startdate=value
     when "Log_file"
      log=value
    end

    end
   }
  
  else
   puts ":::::: Session: #{x} \n" 
   yml[x].each { |key,value|
    puts "#{key} - #{value}"
    case key
     when "Argv"
      cmd2exe="#{cmd} #{value} >> #{log}"
      count+=1
     when "Date"
      date=value
      count+=1
     when "Label"
      label=value
      count+=1
    end

    if count == 3
     lock = Mutex.new
     scheduler.cron date :mutex => [lock] do
      ret=execute(cmd,cmd2exe)
      puts ret
      puts "--------------------"
      puts label
      puts "process"
     end
     count=0
    end
   }
  end
puts name
 
}

scheduler.join
