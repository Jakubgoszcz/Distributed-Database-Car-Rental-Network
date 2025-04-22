-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'Samochody', @optname = N'merge publish', @value = N'true'
GO

-- Adding the merge publication
use [Samochody]
exec sp_addmergepublication @publication = N'wypozyczalnia', @description = N'Merge publication of database ''Samochody'' from Publisher ''DESKTOP-NGSS3D0''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'false', @alt_snapshot_folder = N'C:\xd', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = N'false', @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
GO


exec sp_addpublication_snapshot @publication = N'wypozyczalnia', @frequency_type = 4, @frequency_interval = 14, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 2, @frequency_subday_interval = 10, @active_start_time_of_day = 500, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1
exec sp_grant_publication_access @publication = N'wypozyczalnia', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'wypozyczalnia', @login = N'DESKTOP-NGSS3D0\goszc'
GO
exec sp_grant_publication_access @publication = N'wypozyczalnia', @login = N'NT SERVICE\Winmgmt'
GO
exec sp_grant_publication_access @publication = N'wypozyczalnia', @login = N'NT SERVICE\SQLWriter'
GO
exec sp_grant_publication_access @publication = N'wypozyczalnia', @login = N'NT SERVICE\SQLSERVERAGENT'
GO
exec sp_grant_publication_access @publication = N'wypozyczalnia', @login = N'NT Service\MSSQLSERVER'
GO
exec sp_grant_publication_access @publication = N'wypozyczalnia', @login = N'distributor_admin'
GO

-- Adding the merge articles
use [Samochody]
exec sp_addmergearticle @publication = N'wypozyczalnia', @article = N'Samochody_EXCEL', @source_owner = N'dbo', @source_object = N'Samochody_EXCEL', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO

-- Adding the merge subscriptions
use [Samochody]
exec sp_addmergesubscription @publication = N'wypozyczalnia', @subscriber = N'DESKTOP-NGSS3D0', @subscriber_db = N'Wypozyczalnia', @subscription_type = N'Push', @sync_type = N'Automatic', @subscriber_type = N'Global', @subscription_priority = 75, @description = N'', @use_interactive_resolver = N'False'
exec sp_addmergepushsubscription_agent @publication = N'wypozyczalnia', @subscriber = N'DESKTOP-NGSS3D0', @subscriber_db = N'Wypozyczalnia', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @publisher_security_mode = 1, @frequency_type = 4, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 2, @frequency_subday_interval = 10, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0
GO

