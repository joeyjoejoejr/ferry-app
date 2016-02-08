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
  ^
  (?:(?!one\sboat).)*       # Not one boat
  (?:
  concluded |                                           # end of day
  ended |
  (?:out\sof|not\sin|will\snot\sbe\sin)\sservice |      # out of service
  service\sinterruption |
  shut\sdown
  )
/ix

reason_pattern = /
  (?:
  due\s(?:to\s)?(?:an?\s)?
  ([\w\s]+)           # reason
  \. |
  out\sof\sservice
  .*
  (?:while\s
  ([\w\s]+)           # reason
  \.
  )
  )
/ix

messages = File.readlines "messages"
start_events, other = messages.partition { |text| text.match start_pattern }
stop_events, other = other.partition { |text| text.match stop_pattern }
out_of_service_events, stop_events = stop_events.partition { |text| text.match reason_pattern }
out_of_service_reasons = out_of_service_events.map { |text|
  data = text.match(reason_pattern)
  data[1] || data[2]
}.uniq


File.open("start.txt", "w+") { |file| file.puts start_events }
File.open("stop.txt", "w+") { |file| file.puts stop_events }
File.open("oos.txt", "w+") { |file| file.puts out_of_service_events }
File.open("reasons.txt", "w+") { |file| file.puts out_of_service_reasons }
File.open("other.txt", "w+") { |file| file.puts other }
