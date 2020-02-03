#Variables
input_file='/tmp/ip-nodetype.txt'
stackrc_file='/home/stack/stackrc'
openstack_user='heat-admin'
report_file='/tmp/diff-report.txt'
ssh_commands=" rpm -qa | grep openstack && sudo docker ps --format '{{.Image}}' "

#Arrays
declare IP_NodeType_Array Controller_IP_array ComputeDpdkHw0_IP_array CephStorageHw10_IP_array AppformixController_IP_array ContrailController_IP_array ContrailAnalyticsDatabase_IP_array ContrailAnalytics_IP_array
Controller_IP_array=( init )
ComputeDpdkHw0_IP_array=( init )
CephStorageHw10_IP_array=( init )
AppformixController_IP_array=( init )
ContrailController_IP_array=( init )
ContrailAnalyticsDatabase_IP_array=( init )
ContrailAnalytics_IP_array=( init )

#Reset data files
cat /dev/null > $report_file
cat /dev/null > $input_file

#Collect IP and NodeType information from Undercloud and sort nodes per types
source $stackrc_file
openstack server list | awk '{print $8, $12}' | awk -F= '{print $2}' | awk '!/^$/' >> $input_file
sort -k2 $input_file > /tmp/sort_buffer; cp /tmp/sort_buffer $input_file

#SSH to each node, collect datas, copy them locally in NodeType-IP filename and sort the datas to make the comparison output easier to read
while read file_line; 
do IP_NodeType_Array=($file_line);
ssh -l $openstack_user ${IP_NodeType_Array[0]} $ssh_commands > /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} < /dev/null; 
sort /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} > /tmp/sort_buffer; cp /tmp/sort_buffer /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]};
done < $input_file

#Loop going through the list of IPs/NodeType and comparing the NodeType-IP files
while read file_line; 
do IP_NodeType_Array=($file_line); declare IP_NodeType_Array;
echo '*****' Node: ${IP_NodeType_Array[0]} ${IP_NodeType_Array[1]} '*****' >> $report_file
        # case to split node per type and compare datas with the first node of the list only
        case ${IP_NodeType_Array[1]} in
                "Controller") 
                              # Check if the variable has been used already, if not, will initilize it with the first node IP of the list 
                              # and this will be used to compare with all the other node IPs in the same category
                              if [ ${Controller_IP_array[0]} = "init" ]
                              then
                                Controller_IP_array=${IP_NodeType_Array[0]}
                              fi
                              diff /tmp/${IP_NodeType_Array[1]}-${Controller_IP_array[0]} /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} >> $report_file ;;
                "ComputeDpdkHw0")
                              if [ ${ComputeDpdkHw0_IP_array[0]} = "init" ]
                              then
                                ComputeDpdkHw0_IP_array=${IP_NodeType_Array[0]}
                              fi
                              diff /tmp/${IP_NodeType_Array[1]}-${ComputeDpdkHw0_IP_array[0]} /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} >> $report_file ;;
                "CephStorageHw10")
                              if [ ${CephStorageHw10_IP_array[0]} = "init" ]
                              then
                                CephStorageHw10_IP_array=${IP_NodeType_Array[0]}
                              fi
                              diff /tmp/${IP_NodeType_Array[1]}-${CephStorageHw10_IP_array[0]} /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} >> $report_file ;;
                "AppformixController")
                              if [ ${AppformixController_IP_array[0]} = "init" ]
                              then
                                AppformixController_IP_array=${IP_NodeType_Array[0]}
                              fi
                              diff /tmp/${IP_NodeType_Array[1]}-${AppformixController_IP_array[0]} /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} >> $report_file ;;
                "ContrailController")
                              if [ ${ContrailController_IP_array[0]} = "init" ]
                              then
                                ContrailController_IP_array=${IP_NodeType_Array[0]}
                              fi
                              diff /tmp/${IP_NodeType_Array[1]}-${ContrailController_IP_array[0]} /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} >> $report_file ;;
                "ContrailAnalyticsDatabase")
                              if [ ${ContrailAnalyticsDatabase_IP_array[0]} = "init" ]
                              then
                                ContrailAnalyticsDatabase_IP_array=${IP_NodeType_Array[0]}
                              fi
                              diff /tmp/${IP_NodeType_Array[1]}-${ContrailAnalyticsDatabase_IP_array[0]} /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} >> $report_file ;;
                "ContrailAnalytics")
                              if [ ${ContrailAnalytics_IP_array[0]} = "init" ]
                              then
                                ContrailAnalytics_IP_array=${IP_NodeType_Array[0]}
                              fi
                              diff /tmp/${IP_NodeType_Array[1]}-${ContrailAnalytics_IP_array[0]} /tmp/${IP_NodeType_Array[1]}-${IP_NodeType_Array[0]} >> $report_file ;;
                *) echo "Invalid condition, exiting"
                   exit 1 ;;
        esac
done < $input_file
echo Report: $report_file
