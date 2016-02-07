start_pattern = /
  ^
  (?:(?!second).)*        # not the second ferry
  (?:
  begun |                 # beginning of day
  began |
  (?:now|currently|is)\sin\sservice |
  currently\soperating |
  (?:has\sgone|will\snow\sbe)\sin\sservice |
  is\soperating |
  (?:will\s*|has)\sbegin |
  resumed |               # Resumed after stopping
  resuming |
  is\sback |
  has\sreturned\sto\snormal
  )
  (?:(?<!second).)*       # not the second ferry
  $
/ix

stop_pattern = /
  (?:
  concluded |                                           # end of day
  ended |
  (?:out\sof|not\sin|will\snot\sbe\sin)\sservice |      # out of service
  service\sinterruption |
  shut\sdown
  )
/ix

messages = File.readlines "messages"
start_events, other = messages.partition { |text| text =~ start_pattern }
stop_events, other = other.partition { |text| text =~ stop_pattern }

File.open("start.txt", "w+") { |file| file.puts start_events }
File.open("stop.txt", "w+") { |file| file.puts stop_events }
File.open("other.txt", "w+") { |file| file.puts other }
