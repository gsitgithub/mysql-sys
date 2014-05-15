/* Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA */

DROP PROCEDURE IF EXISTS ps_setup_disable_comsumers;

DELIMITER $$

CREATE DEFINER='root'@'localhost' PROCEDURE ps_setup_disable_comsumers (
        IN consumer VARCHAR(128)
    )
    COMMENT '
             Description
             -----------

             Disables consumers within Performance Schema 
             matching the input pattern.

             Requires the SUPER privilege for "SET sql_log_bin = 0;".

             Parameters
             -----------

             consumer (VARCHAR(128)):
               A LIKE pattern match (using "%consumer%") of consumers to disable

             Example
             -----------

             To disable all consumers:

             mysql> CALL sys.ps_setup_disable_comsumers(\'\');
             +--------------------------+
             | summary                  |
             +--------------------------+
             | Disabled 15 consumers    |
             +--------------------------+
             1 row in set (0.02 sec)

             To disable just the event_stage consumers:

             mysql> CALL sys.ps_setup_disable_comsumers(\'stage\');
             +------------------------+
             | summary                |
             +------------------------+
             | Disabled 3 consumers   |
             +------------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN
    SET @log_bin := @@sql_log_bin;
    SET sql_log_bin = 0;

    UPDATE performance_schema.setup_consumers
       SET enabled = 'NO'
     WHERE name LIKE CONCAT('%', consumer, '%');

    SELECT CONCAT('Disabled ', @rows := ROW_COUNT(), ' consumer', IF(@rows != 1, 's', '')) AS summary;

    SET sql_log_bin = @log_bin; 
END$$

DELIMITER ;