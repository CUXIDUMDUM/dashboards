SCHEDULER.every '1h', :first_in => 0 do
  
  send_event('previous-lectures', LectureList.update("Completed") )

end