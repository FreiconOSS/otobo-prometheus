# WIP: Prometheus package for OTOBO

## example
```shell
# HELP otobo_info Information about the otobo environment
# TYPE otobo_info counter
otobo_info{version="10.0.6"} 1
# HELP otobo_package_installed 
# TYPE otobo_package_installed counter
otobo_package_installed{name="DynamicField_SameRow",version="10.0.0.1.g4b412ab",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="FREICON-Skin",version="10.0.1",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="Idoit-Connector",version="10.1.0",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="TEMPLATE-Skin",version="10.0.1.3.g8c01a0e",vendor="FREICON GmbH & Co. KG"} 1
otobo_package_installed{name="TextModules",version="10.0.2.1.g5b31148",vendor="FREICON GmbH & Co. KG"} 1
# HELP otobo_sysconfig_default_count 
# TYPE otobo_sysconfig_default_count gauge
otobo_sysconfig_default_count 2158
# HELP otobo_sysconfig_deployment 
# TYPE otobo_sysconfig_deployment counter
otobo_sysconfig_deployment 9
# HELP otobo_sysconfig_modified_count 
# TYPE otobo_sysconfig_modified_count gauge
otobo_sysconfig_modified_count 1
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
# HELP perl_info Information about the perl environment
# TYPE perl_info counter
perl_info{version="5.030000"} 1
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 0.71
# HELP process_cpu_system_seconds_total Total system CPU time spent in seconds
# TYPE process_cpu_system_seconds_total counter
process_cpu_system_seconds_total 0.13
# HELP process_cpu_user_seconds_total Total user CPU time spent in seconds
# TYPE process_cpu_user_seconds_total counter
process_cpu_user_seconds_total 0.58
# HELP process_max_fds Maximum number of allowed file handles
# TYPE process_max_fds gauge
process_max_fds 8192
# HELP process_open_fds Number of open file handles
# TYPE process_open_fds gauge
process_open_fds 18
# HELP process_resident_memory_bytes Resident memory size in bytes
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 163938304
# HELP process_start_time_seconds Unix epoch time the process started at
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1614273393.51
# HELP process_virtual_memory_bytes Virtual memory size in bytes
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 1894674432
```
