# WIP: Prometheus package for OTOBO
Descriptions are missing everywhere!  :eyes:
## Plugins
- Article
- CommunicationStats
- DatabaseRecords
- MailQueue
- Maintenance
- OTOBO
- Packages
- Perl
- Session
- Skin
- SysConfig
- SystemID
- Themes
- TicketStats
- TicketsWithInvalidUser
- TimeAccounted
- TimeBetweenFirstAndLastTicket

plugins can be disabled via sysconfig

## example
```shell
# HELP otobo_agent_theme_usage 
# TYPE otobo_agent_theme_usage gauge
# HELP otobo_article_count 
# TYPE otobo_article_count counter
otobo_article_count{channel="Email",sender="customer"} 1
otobo_article_count{channel="Phone",sender="customer"} 3
# HELP otobo_communication_stats 
# TYPE otobo_communication_stats gauge
otobo_communication_stats{direction="Outgoing",status="Failed"} 834
otobo_communication_stats{direction="Outgoing",status="Processing"} 7
# HELP otobo_database_record_count 
# TYPE otobo_database_record_count gauge
otobo_database_record_count{type="AgentCount"} 1
otobo_database_record_count{type="ArticleCount"} 4
otobo_database_record_count{type="AttachmentCountDBNonHTML"} 0
otobo_database_record_count{type="DistinctTicketCustomerCount"} 0
otobo_database_record_count{type="DynamicFieldCount"} 2
otobo_database_record_count{type="DynamicFieldValueCount"} 0
otobo_database_record_count{type="GroupCount"} 3
otobo_database_record_count{type="InvalidDynamicFieldCount"} 0
otobo_database_record_count{type="InvalidDynamicFieldValueCount"} 0
otobo_database_record_count{type="ProcessCount"} 0
otobo_database_record_count{type="ProcessTickets"} 0
otobo_database_record_count{type="QueueCount"} 4
otobo_database_record_count{type="RoleCount"} 0
otobo_database_record_count{type="ServiceCount"} 0
otobo_database_record_count{type="TicketCount"} 4
otobo_database_record_count{type="TicketHistoryCount"} 9
otobo_database_record_count{type="WebserviceCount"} 1
# HELP otobo_info Information about the otobo environment
# TYPE otobo_info counter
otobo_info{version="10.0.6",lang="de",tz="UTC",org="Example Company"} 1
# HELP otobo_locked_ticked_with_invalid_user 
# TYPE otobo_locked_ticked_with_invalid_user gauge
otobo_locked_ticked_with_invalid_user 0
# HELP otobo_mail_queue_count 
# TYPE otobo_mail_queue_count counter
otobo_mail_queue_count 7
# HELP otobo_maintenance_active 
# TYPE otobo_maintenance_active gauge
otobo_maintenance_active 1
# HELP otobo_package_installed 
# TYPE otobo_package_installed counter
otobo_package_installed{name="DynamicField_SameRow",version="10.0.0.1.g4b412ab",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="FREICON-Skin",version="10.0.1",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="Idoit-Connector",version="10.1.0",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="TEMPLATE-Skin",version="10.0.1.3.g8c01a0e",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="TextModules",version="10.0.2.1.g5b31148",vendor="FREICON GmbH & Co. KG"} 1
# HELP otobo_prometheus_plugin_execute_took_seconds 
# TYPE otobo_prometheus_plugin_execute_took_seconds gauge
otobo_prometheus_plugin_execute_took_seconds{name="Article"} 0.000622
otobo_prometheus_plugin_execute_took_seconds{name="CommunicationStats"} 0.003897
otobo_prometheus_plugin_execute_took_seconds{name="DatabaseRecords"} 0.011897
otobo_prometheus_plugin_execute_took_seconds{name="MailQueue"} 0.002766
otobo_prometheus_plugin_execute_took_seconds{name="Maintenance"} 0.001729
otobo_prometheus_plugin_execute_took_seconds{name="OTOBO"} 0.000354
otobo_prometheus_plugin_execute_took_seconds{name="Packages"} 0.000732
otobo_prometheus_plugin_execute_took_seconds{name="Perl"} 7.7e-05
otobo_prometheus_plugin_execute_took_seconds{name="Session"} 0.004192
otobo_prometheus_plugin_execute_took_seconds{name="SysConfig"} 0.028498
otobo_prometheus_plugin_execute_took_seconds{name="SystemID"} 0.000272
otobo_prometheus_plugin_execute_took_seconds{name="Themes"} 0.000588
otobo_prometheus_plugin_execute_took_seconds{name="TicketStats"} 0.001336
otobo_prometheus_plugin_execute_took_seconds{name="TicketsWithInvalidUser"} 0.000465
otobo_prometheus_plugin_execute_took_seconds{name="TimeAccounted"} 0.00071
otobo_prometheus_plugin_execute_took_seconds{name="TimeBetweenFirstAndLastTicket"} 0.002063
# HELP otobo_seconds_between_first_and_last_ticket 
# TYPE otobo_seconds_between_first_and_last_ticket gauge
otobo_seconds_between_first_and_last_ticket 109
# HELP otobo_sessions_count 
# TYPE otobo_sessions_count gauge
otobo_sessions_count{user_type="Customer"} 0
otobo_sessions_count{user_type="User"} 1
# HELP otobo_sessions_unique_count 
# TYPE otobo_sessions_unique_count gauge
otobo_sessions_unique_count{user_type="Customer"} 0
otobo_sessions_unique_count{user_type="User"} 1
# HELP otobo_sysconfig_default_count 
# TYPE otobo_sysconfig_default_count gauge
otobo_sysconfig_default_count 2174
# HELP otobo_sysconfig_deployment 
# TYPE otobo_sysconfig_deployment counter
otobo_sysconfig_deployment 12
# HELP otobo_sysconfig_modified_count 
# TYPE otobo_sysconfig_modified_count gauge
otobo_sysconfig_modified_count 1
# HELP otobo_system_id 
# TYPE otobo_system_id gauge
otobo_system_id 10
# HELP otobo_ticket_count 
# TYPE otobo_ticket_count gauge
otobo_ticket_count{queue="Misc",ticket_type="null",service="null",ticket_priority="4 high",ticket_state="open"} 2
otobo_ticket_count{queue="Postmaster",ticket_type="null",service="null",ticket_priority="4 high",ticket_state="open"} 1
otobo_ticket_count{queue="Raw",ticket_type="Unclassified",service="null",ticket_priority="1 very low",ticket_state="new"} 1
# HELP otobo_ticket_history_count 
# TYPE otobo_ticket_history_count counter
otobo_ticket_history_count{type="NewTicket"} 4
otobo_ticket_history_count{type="PhoneCallCustomer"} 3
otobo_ticket_history_count{type="TimeAccounting"} 2
# HELP otobo_time_accounted_total 
# TYPE otobo_time_accounted_total counter
otobo_time_accounted_total 6
# HELP perl_info Information about the perl environment
# TYPE perl_info counter
perl_info{version="5.030000"} 1
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 0.89
# HELP process_cpu_system_seconds_total Total system CPU time spent in seconds
# TYPE process_cpu_system_seconds_total counter
process_cpu_system_seconds_total 0.16
# HELP process_cpu_user_seconds_total Total user CPU time spent in seconds
# TYPE process_cpu_user_seconds_total counter
process_cpu_user_seconds_total 0.73
# HELP process_max_fds Maximum number of allowed file handles
# TYPE process_max_fds gauge
process_max_fds 8192
# HELP process_open_fds Number of open file handles
# TYPE process_open_fds gauge
process_open_fds 18
# HELP process_resident_memory_bytes Resident memory size in bytes
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 169791488
# HELP process_start_time_seconds Unix epoch time the process started at
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1614344832.75
# HELP process_virtual_memory_bytes Virtual memory size in bytes
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 1895075840
```

