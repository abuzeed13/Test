/system scheduler
add interval=5s name=Telegram on-event="/system script run tg_getUpdates" \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup

/system script
add dont-require-permissions=no name=tg_getUpdates owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:global TGLASTMSGID\r\
    \n:global TGLASTUPDID\r\
    \n\r\
    \n:local fconfig [:parse [/system script get tg_config source]]\r\
    \n:local http [:parse [/system script get func_fetch source]]\r\
    \n:local gkey [:parse [/system script get tg_getkey source]]\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n:local cfg [\$fconfig]\r\
    \n:local trusted [:toarray (\$cfg->\"trusted\")]\r\
    \n:local botID (\$cfg->\"botAPI\")\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n:local timeout (\$cfg->\"timeout\")\r\
    \n\r\
    \n:put \"cfg=\$cfg\"\r\
    \n:put \"trusted=\$trusted\"\r\
    \n:put \"botID=\$botID\"\r\
    \n:put \"storage=\$storage\"\r\
    \n:put \"timeout=\$timeout\"\r\
    \n\r\
    \n:local file (\$storage.\"tg_get_updates.txt\")\r\
    \n:local logfile (\$storage.\"tg_fetch_log.txt\")\r\
    \n#get 1 message per time\r\
    \n:local url (\"https://api.telegram.org/bot\".\$botID.\"/getUpdates\?time\
    out=\$timeout&limit=1\")\r\
    \n:if ([:len \$TGLASTUPDID]>0) do={\r\
    \n  :set url \"\$url&offset=\$(\$TGLASTUPDID+1)\"\r\
    \n}\r\
    \n\r\
    \n:put \"Reading updates...\"\r\
    \n:local res [\$http dst-path=\$file url=\$url resfile=\$logfile]\r\
    \n:if (\$res!=\"success\") do={\r\
    \n  :put \"Error getting updates\"\r\
    \n  return \"Failed get updates\"\r\
    \n}\r\
    \n:put \"Finished to read updates.\"\r\
    \n\r\
    \n:local content [/file get [/file find name=\$file] contents]\r\
    \n\r\
    \n:local msgid [\$gkey key=\"message_id\" text=\$content]\r\
    \n:if (\$msgid=\"\") do={ \r\
    \n :put \"No new updates\"\r\
    \n :return 0 \r\
    \n}\r\
    \n:set TGLASTMSGID \$msgid\r\
    \n\r\
    \n:local updid [\$gkey key=\"update_id\" text=\$content]\r\
    \n:set TGLASTUPDID \$updid\r\
    \n\r\
    \n:local fromid [\$gkey block=\"from\" key=\"id\" text=\$content]\r\
    \n:local username [\$gkey block=\"from\" key=\"username\" text=\$content]\
    \r\
    \n:local firstname [\$gkey block=\"from\" key=\"first_name\" text=\$conten\
    t]\r\
    \n:local lastname [\$gkey block=\"from\" key=\"last_name\" text=\$content]\
    \r\
    \n:local chatid [\$gkey block=\"chat\" key=\"id\" text=\$content]\r\
    \n:local chattext [\$gkey block=\"chat\" key=\"text\" text=\$content]\r\
    \n\r\
    \n:put \"message id=\$msgid\"\r\
    \n:put \"update id=\$updid\"\r\
    \n:put \"from id=\$fromid\"\r\
    \n:put \"first name=\$firstname\"\r\
    \n:put \"last name=\$lastname\"\r\
    \n:put \"username=\$username\"\r\
    \n:local name \"\$firstname \$lastname\"\r\
    \n:if ([:len \$name]<2) do {\r\
    \n :set name \$username\r\
    \n}\r\
    \n\r\
    \n:put \"in chat=\$chatid\"\r\
    \n:put \"command=\$chattext\"\r\
    \n\r\
    \n:local allowed ( [:type [:find \$trusted \$fromid]]!=\"nil\" or [:type [\
    :find \$trusted \$chatid]]!=\"nil\")\r\
    \n:if (!\$allowed) do={\r\
    \n :put \"Unknown sender, keep silence\"\r\
    \n :return -1\r\
    \n}\r\
    \n\r\
    \n:local cmd \"\"\r\
    \n:local params \"\"\r\
    \n:local ltext [:len \$chattext]\r\
    \n\r\
    \n:local pos [:find \$chattext \" \"]\r\
    \n:if ([:type \$pos]=\"nil\") do={\r\
    \n :set cmd [:pick \$chattext 1 \$ltext]\r\
    \n} else={\r\
    \n :set cmd [:pick \$chattext 1 \$pos]\r\
    \n :set params [:pick \$chattext (\$pos+1) \$ltext]\r\
    \n}\r\
    \n\r\
    \n:local pos [:find \$cmd \"@\"]\r\
    \n:if ([:type \$pos]!=\"nil\") do={\r\
    \n :set cmd [:pick \$cmd 0 \$pos]\r\
    \n}\r\
    \n\r\
    \n:put \"cmd=<\$cmd>\"\r\
    \n:put \"params=<\$params>\"\r\
    \n\r\
    \n:global TGLASTCMD \$cmd\r\
    \n\r\
    \n:put \"Try to invoke external script tg_cmd_\$cmd\"\r\
    \n:local script [:parse [/system script get \"tg_cmd_\$cmd\" source]]\r\
    \n\$script params=\$params chatid=\$chatid from=\$name"
add dont-require-permissions=no name=func_fetch owner=admin policy=\
    ftp,read,write,policy,test source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n#########################################################\r\
    \n# Wrapper for /tools fetch\r\
    \n#  Input:\r\
    \n#    mode\r\
    \n#    upload=yes/no\r\
    \n#    user\r\
    \n#    password\r\
    \n#    address\r\
    \n#    host\r\
    \n#    httpdata\r\
    \n#    httpmethod\r\
    \n#    check-certificate\r\
    \n#    src-path\r\
    \n#    dst-path\r\
    \n#    ascii=yes/no\r\
    \n#    url\r\
    \n#    resfile\r\
    \n\r\
    \n:local res \"fetchresult.txt\"\r\
    \n:if ([:len \$resfile]>0) do={:set res \$resfile}\r\
    \n#:put \$res\r\
    \n\r\
    \n:local cmd \"/tool fetch\"\r\
    \n:if ([:len \$mode]>0) do={:set cmd \"\$cmd mode=\$mode\"}\r\
    \n:if ([:len \$upload]>0) do={:set cmd \"\$cmd upload=\$upload\"}\r\
    \n:if ([:len \$user]>0) do={:set cmd \"\$cmd user=\\\"\$user\\\"\"}\r\
    \n:if ([:len \$password]>0) do={:set cmd \"\$cmd password=\\\"\$password\\\
    \"\"}\r\
    \n:if ([:len \$address]>0) do={:set cmd \"\$cmd address=\\\"\$address\\\"\
    \"}\r\
    \n:if ([:len \$host]>0) do={:set cmd \"\$cmd host=\\\"\$host\\\"\"}\r\
    \n:if ([:len \$\"http-data\"]>0) do={:set cmd \"\$cmd http-data=\\\"\$\"ht\
    tp-data\"\\\"\"}\r\
    \n:if ([:len \$\"http-method\"]>0) do={:set cmd \"\$cmd http-method=\\\"\$\
    \"http-method\"\\\"\"}\r\
    \n:if ([:len \$\"check-certificate\"]>0) do={:set cmd \"\$cmd check-certif\
    icate=\\\"\$\"check-certificate\"\\\"\"}\r\
    \n:if ([:len \$\"src-path\"]>0) do={:set cmd \"\$cmd src-path=\\\"\$\"src-\
    path\"\\\"\"}\r\
    \n:if ([:len \$\"dst-path\"]>0) do={:set cmd \"\$cmd dst-path=\\\"\$\"dst-\
    path\"\\\"\"}\r\
    \n:if ([:len \$ascii]>0) do={:set cmd \"\$cmd ascii=\\\"\$ascii\\\"\"}\r\
    \n:if ([:len \$url]>0) do={:set cmd \"\$cmd url=\\\"\$url\\\"\"}\r\
    \n\r\
    \n:put \">> \$cmd\"\r\
    \n\r\
    \n:global FETCHRESULT\r\
    \n:set FETCHRESULT \"none\"\r\
    \n\r\
    \n:local script \"\\\r\
    \n :global FETCHRESULT;\\\r\
    \n :do {\\\r\
    \n   \$cmd;\\\r\
    \n   :set FETCHRESULT \\\"success\\\";\\\r\
    \n } on-error={\\\r\
    \n  :set FETCHRESULT \\\"failed\\\";\\\r\
    \n }\\\r\
    \n\"\r\
    \n:execute script=\$script file=\$res\r\
    \n:local cnt 0\r\
    \n#:put \"\$cnt -> \$FETCHRESULT\"\r\
    \n:while (\$cnt<100 and \$FETCHRESULT=\"none\") do={ \r\
    \n :delay 1s\r\
    \n :set \$cnt (\$cnt+1)\r\
    \n #:put \"\$cnt -> \$FETCHRESULT\"\r\
    \n}\r\
    \n:local content [/file get [find name=\$res] content]\r\
    \n#:put \$content\r\
    \nif (\$content~\"finished\") do={:return \"success\"}\r\
    \n:return \$FETCHRESULT"
add dont-require-permissions=no name=tg_getkey owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local cur 0\r\
    \n:local lkey [:len \$key]\r\
    \n:local res \"\"\r\
    \n:local p\r\
    \n\r\
    \n:if ([:len \$block]>0) do={\r\
    \n :set p [:find \$text \$block \$cur]\r\
    \n :if ([:type \$p]=\"nil\") do={\r\
    \n  :return \$res\r\
    \n }\r\
    \n :set cur (\$p+[:len \$block]+2)\r\
    \n}\r\
    \n\r\
    \n:set p [:find \$text \$key \$cur]\r\
    \n:if ([:type \$p]!=\"nil\") do={\r\
    \n :set cur (\$p+lkey+2)\r\
    \n :set p [:find \$text \",\" \$cur]\r\
    \n :if ([:type \$p]!=\"nil\") do={\r\
    \n   if ([:pick \$text \$cur]=\"\\\"\") do={\r\
    \n    :set res [:pick \$text (\$cur+1) (\$p-1)]\r\
    \n   } else={\r\
    \n    :set res [:pick \$text \$cur \$p]\r\
    \n   }\r\
    \n } \r\
    \n}\r\
    \n:return \$res"
add dont-require-permissions=no name=tg_sendMessage owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local fconfig [:parse [/system script get tg_config source]]\r\
    \n\r\
    \n:local cfg [\$fconfig]\r\
    \n:local chatID (\$cfg->\"defaultChatID\")\r\
    \n:local botID (\$cfg->\"botAPI\")\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n\r\
    \n:if ([:len \$chat]>0) do={:set chatID \$chat}\r\
    \n\r\
    \n:local url \"https://api.telegram.org/bot\$botID/sendmessage\?chat_id=\$\
    chatID&text=\$text\"\r\
    \n:if ([:len \$mode]>0) do={:set url (\$url.\"&parse_mode=\$mode\")}\r\
    \n\r\
    \n:local file (\$tgStorage.\"tg_get_updates.txt\")\r\
    \n:local logfile (\$tgStorage.\"tg_fetch_log.txt\")\r\
    \n\r\
    \n/tool fetch url=\$url keep-result=no"
add dont-require-permissions=no name=tg_cmd_cpu owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local hotspot [:len [/ip hotspot active find]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n \r\
    \n:local text \"Router Id:* \$[/system identity get name] * %0A\\\r\
    \nBoard: _\$[/system resource get board-name]_%0A\\\r\
    \nVersion: _\$[/system resource get version]_%0A\\\r\
    \nTime: _\$[/system resource get build-time]_%0A\\\r\
    \nUptime: _\$[/system resource get uptime]_%0A\\\r\
    \nCPU Load: *\$[/system resource get cpu-load]%*%0A\\\r\
    \nRAM: _\$(([/system resource get total-memory]-[/system resource get free\
    -memory])/(1024*1024))M/\$([/system resource get total-memory]/(1024*1024)\
    )M_%0A\\\r\
    \nVoltage: *\$[:pick [/system health get voltage] 0 2]V*%0A\\\r\
    \nTemp: *\$[ /system health get temperature]C*\"\r\
    \n \r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
add dont-require-permissions=no name=tg_cmd_start owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:local text \"Router Id:* \$[/system identity get name] * %0A\\\r\
    \n========================%0A\\\r\
    \n=========MENU=========%0A\\\r\
    \n======BY ABU ZEED======%0A\\\r\
    \n========================%0A\\\r\
    \n(/cpu) --- (/ping) --- (/public)%0A\\\r\
    \n%0A\\\r\
    \n(/pppActive) --- (/hotspotActive)%0A\\\r\
    \n%0A\\\r\
    \n(/ubnt)%0A\\\r\
    \n%0A\\\r\
    \n(/eHotspot) --- (/dHotspot)%0A\\\r\
    \n\r\
    \n=======(/reboot)=======%0A\\\r\
    \n%0A\\\r\
    \n\\D8\\B4\\D8\\B1\\D8\\AD\\20\\D8\\A7\\D9\\84\\D8\\A5\\D8\\B3\\D8\\AA\\D8\
    \\AE\\D8\\AF\\D8\\A7\\D9\\85%0A\\\r\
    \n========(/Info)=======\"\r\
    \n\r\
    \n\r\
    \n \r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
add dont-require-permissions=no name=tg_cmd_public owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:local public;\r\
    \n\
    \n:local ddns;\r\
    \n\
    \n:set public [/ip cloud get public-address];\r\
    \n\
    \n:set ddns [/ip cloud get dns-name];\r\
    \n\
    \n:local text \"DDNS : \$ddns : IP Public : \$public\"\r\
    \n\r\
    \n\r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\""
add dont-require-permissions=no name=tg_cmd_ping owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    #####################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n#Ping Variables\r\
    \n:local avgRtt;\r\
    \n:local pin\r\
    \n:local pout\r\
    \n:local datetime \"\$[/system clock get date] \$[/system clock get time]\
    \"\r\
    \n#Ping it real good\r\
    \n/tool flood-ping 8.8.8.8 count=10 do={\r\
    \n  \r\
    \n:if (\$sent = 10) do={\r\
    \n    \r\
    \n:set avgRtt \$\"avg-rtt\"\r\
    \n    \r\
    \n:set pout \$sent\r\
    \n    \r\
    \n:set pin \$received\r\
    \n  }\r\
    \n\r\
    \n}\r\
    \n\r\
    \n:local ploss (100 - ((\$pin * 100) / \$pout))\r\
    \n\r\
    \n:local logmsg (\"Ping Average for 8.8.8.8 - \".[:tostr \$avgRtt].\"ms - \
    packet loss: \".[:tostr \$ploss].\"%\")\r\
    \n\r\
    \n:log info \$logmsg\r\
    \n\r\
    \n:local text \"Router Id:* \$[/system identity get name] * %0A\\\r\
    \nTanggal : _\$datetime_%0A\\\r\
    \nPing : _8.8.8.8_%0A\\\r\
    \nLog : _\$logmsg_\"\r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
add dont-require-permissions=no name=tg_cmd_dHotspot owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    #####################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:local text \"Hotspot Disable\"\r\
    \n\r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n/ip hotspot disable hotspot"
add dont-require-permissions=no name=tg_cmd_eHotspot owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    #####################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:local text \"Hotspot Enable\"\r\
    \n\r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n/ip hotspot enable hotspot"
add dont-require-permissions=no name=tg_config owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    #####################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n# to use config insert next lines:\r\
    \n#:local fconfig [:parse [/system script get tg_config source]]\r\
    \n#:local config [\$fconfig]\r\
    \n#:put \$config\r\
    \n\r\
    \n######################################\r\
    \n# ABU ZEED\r\
    \n######################################\r\
    \n\r\
    \n:local config {\r\
    \n\"Command\"=\"telegram\";\r\
    \n\t\"botAPI\"=\"1087954117:AAEJmiv-2sqTHvFoxX62PSGaC7ISCgtmKAs\";\r\
    \n\t\"defaultChatID\"=\"602289885\";\r\
    \n\t\"trusted\"=\"602289885,527168723\";\r\
    \n\t\"storage\"=\"\";\r\
    \n\t\"timeout\"=1;\r\
    \n\t\"refresh_active\"=15;\r\
    \n\t\"refresh_standby\"=300;\r\
    \n}\r\
    \nreturn \$config"
add dont-require-permissions=no name=tg_cmd_pppActive owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local hotspot [:len [/ip hotspot active find]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:local text \"PPP Active:*\$[:len [/ppp active find service=pppoe]]*\"\r\
    \n\r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
add dont-require-permissions=no name=tg_cmd_hotspotActive owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    #####################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local hotspot [:len [/ip hotspot active find]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n \r\
    \n:local text \"Hotspot Actvie:* \$[:len [/ip hotspot active find]]*\"\r\
    \n \r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
add dont-require-permissions=no name=tg_cmd_h owner=admin policy=read,romon \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local param1 [:pick \$params 0 [:find \$params \" \"]]\r\
    \n:local param2 [:pick \$params ([:find \$params \" \"]+1) [:len \$params]\
    ]\r\
    \n:local param3 [:pick [:pick \$params ([:find \$params \" \"]+1) [:len \$\
    params]] ([:find [:pick \$params ([:find \$params \" \"]+1) [:len \$params\
    ]] \" \"]+1) [:len [:pick \$params ([:find \$params \" \"]+1) [:len \$para\
    ms]]]]\r\
    \n:if ([:len [:find \$param2 \" \"]]>0) do={\r\
    \n\t:set param2 [:pick [:pick \$params ([:find \$params \" \"]+1) [:len \$\
    params]] 0 [:find [:pick \$params ([:find \$params \" \"]+1) [:len \$param\
    s]] \" \"]]\r\
    \n} else={\r\
    \n\t:set param3 \"\"\r\
    \n}\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$param1\r\
    \n:put \$param2\r\
    \n:put \$param3\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:if (\$param1=\"add\") do={\r\
    \n/ip hot user add name=\$param1 password=\$param2  profile=\$param3\r\
    \n\$send chat=\$chatid text=(\"\\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D\
    8\\AE\\D8\\AF\\D9\\85 : \$param2 add\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"delete\") do={\r\
    \n/ip hot user remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"\\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D\
    8\\AE\\D8\\AF\\D9\\85 : \$param2 Berhasil dihapus\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"disable\") do={\r\
    \n/ip hot user disable [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"\\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D\
    8\\AE\\D8\\AF\\D9\\85 : \$param2 \\D8\\AA\\D9\\85\\20\\D8\\A7\\D9\\84\\D8\
    \\AA\\D8\\B9\\D8\\B7\\D9\\8A\\D9\\84\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"enable\") do={\r\
    \n/ip hot user enable [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"\\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D\
    8\\AE\\D8\\AF\\D9\\85 : \$param2 Enable\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"password\") do={\r\
    \n/ip hot user set password=\$param3 [find name=\$param2]\r\
    \n/ip hot active remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"\\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D\
    8\\AE\\D8\\AF\\D9\\85 : \$param2 pasword diganti menjadi \$param3...\") mo\
    de=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"profile\") do={\r\
    \n/ip hot user set profile=\$param3 [find name=\$param2]\r\
    \n/ip hot active remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User \\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\\
    AA\\D8\\AE\\D8\\AF\\D9\\85 : \$param2 profile diganti menjadi \$param3...\
    \") mode=\"Markdown\"\r\
    \n}\r\
    \n\r\
    \n:if (\$param1!=\"password\" and \$param1!=\"profile\" and \$param1!=\"en\
    able\" and \$param1!=\"disable\" and \$param1!=\"delete\" and \$param1!=\"\
    print\") do={\r\
    \n/ip hot user add name=\$param1 password=\$param2 profile=\$param3 \r\
    \n\$send chat=\$chatid text=(\"\\D8\\AA\\D9\\85\\20\\D8\\A7\\D8\\B6\\D8\\A\
    7\\D9\\81\\D8\\A9\\20\\D8\\A7\\D9\\84\\D8\\AD\\D8\\B3\\D8\\A7\\D8\\A8 %0A\
    \\D8\\A5\\D8\\B3\\D9\\85\\20\\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D8\\\
    AE\\D8\\AF\\D9\\85: \$param1 %0A\\D9\\83\\D9\\84\\D9\\85\\D8\\A9\\20\\D8\\\
    A7\\D9\\84\\D9\\85\\D8\\B1\\D9\\88\\D8\\B1: \$param2 %0A\\D8\\A7\\D9\\84\\\
    D8\\A8\\D8\\B1\\D9\\88\\D9\\81\\D8\\A7\\D9\\8A\\D9\\84: \$param3 %0ADone..\
    .\") mode=\"Markdown\"\r\
    \n}\r\
    \n\r\
    \n\r\
    \n\r\
    \n:local output\r\
    \n:foreach activeIndex in=[/ip hotspot user find name=\$params] do={\r\
    \n:local byteout [/ip hotspot user get value-name=\"bytes-out\" \$activeIn\
    dex];\r\
    \n:local bytein [/ip hotspot user get value-name=\"bytes-in\" \$activeInde\
    x];\r\
    \n:local limittotal [/ip hotspot user get value-name=\"limit-bytes-total\"\
    \_\$activeIndex];\r\
    \n:local kuotaterpakai (\"*\\D8\\A5\\D8\\AC\\D9\\85\\D8\\A7\\D9\\84\\D9\\8\
    A\\20\\D8\\A7\\D9\\84\\D8\\A5\\D8\\B3\\D8\\AA\\D8\\AE\\D8\\AF\\D8\\A7\\D9\
    \\85: * \".((\$byteout+\$bytein) / 1024 / 1024).\" Mb %0A\")\r\
    \n:local user (\"*\\D8\\A3\\D8\\B3\\D9\\85\\20\\D8\\A7\\D9\\84\\D9\\85\\D8\
    \\B3\\D8\\AA\\D8\\AE\\D8\\AF\\D9\\85:* \".[/ip hotspot user get value-name\
    =\"name\" \$activeIndex].\"%0A\")\r\
    \n:local password (\"*\\D9\\83\\D9\\84\\D9\\85\\D8\\A9\\20\\D8\\A7\\D9\\84\
    \\D9\\85\\D8\\B1\\D9\\88\\D8\\B1:* \".[/ip hotspot user get value-name=\"p\
    assword\" \$activeIndex].\"%0A\")\r\
    \n:local uptime (\"*\\D8\\A7\\D9\\84\\D9\\88\\D9\\82\\D8\\AA\\20\\D8\\A7\\\
    D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D8\\AE\\D8\\AF\\D9\\85:* \".[/ip hotspot u\
    ser get value-name=\"uptime\" \$activeIndex].\"%0A\")\r\
    \n:local disable (\"*\\D8\\A7\\D9\\84\\D8\\AA\\D8\\B9\\D8\\B7\\D9\\8A\\D9\
    \\84:* \".[/ip hotspot user get value-name=\"disable\" \$activeIndex].\"%0\
    A\")\r\
    \n:local profile (\"*\\D8\\A7\\D9\\84\\D8\\A8\\D8\\B1\\D9\\88\\D9\\81\\D8\
    \\A7\\D9\\8A\\D9\\84:* \".[/ip hotspot user get value-name=\"profile\" \$a\
    ctiveIndex].\"%0A\")\r\
    \n:set output (\$output.\$user.\$password.\$profile.\$uptime.\$disable.\$k\
    uotaterpakai.\"%0A\")\r\
    \n}\r\
    \n\$send chat=\$chatid text=(\"\$output\") mode=\"Markdown\"\r\
    \n"
add dont-require-permissions=no name=tg_cmd_p owner=admin policy=read source="\
    ######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local param1 [:pick \$params 0 [:find \$params \" \"]]\r\
    \n:local param2 [:pick \$params ([:find \$params \" \"]+1) [:len \$params]\
    ]\r\
    \n:local param3 [:pick [:pick \$params ([:find \$params \" \"]+1) [:len \$\
    params]] ([:find [:pick \$params ([:find \$params \" \"]+1) [:len \$params\
    ]] \" \"]+1) [:len [:pick \$params ([:find \$params \" \"]+1) [:len \$para\
    ms]]]]\r\
    \n:if ([:len [:find \$param2 \" \"]]>0) do={\r\
    \n\t:set param2 [:pick [:pick \$params ([:find \$params \" \"]+1) [:len \$\
    params]] 0 [:find [:pick \$params ([:find \$params \" \"]+1) [:len \$param\
    s]] \" \"]]\r\
    \n} else={\r\
    \n\t:set param3 \"\"\r\
    \n}\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$param1\r\
    \n:put \$param2\r\
    \n:put \$param3\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:if (\$param1=\"delete\") do={\r\
    \n/ppp secret remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User PPP: \$param2 Berhasil dihapus\") mode\
    =\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"disable\") do={\r\
    \n/ppp secret disable [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User PPP: \$param2 Disable\") mode=\"Markdo\
    wn\"\r\
    \n}\r\
    \n:if (\$param1=\"enable\") do={\r\
    \n/ppp secret enable [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User PPP: \$param2 Enable\") mode=\"Markdow\
    n\"\r\
    \n}\r\
    \n:if (\$param1=\"password\") do={\r\
    \n/ppp secret set password=\$param3 [find name=\$param2]\r\
    \n/ppp active remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User PPP: \$param2 pasword diganti menjadi \
    \$param3...\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"profile\") do={\r\
    \n/ppp secret set profile=\$param3 [find name=\$param2]\r\
    \n/ppp active remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User PPP: \$param2 profile diganti menjadi \
    \$param3...\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$params=\"print\") do={\r\
    \n:local output\r\
    \n:foreach activeIndex in=[/ppp active find] do={\r\
    \n:local activeUser (\"*Username:* \".[/ppp active get value-name=\"name\"\
    \_\$activeIndex].\"%0A\")\r\
    \n:local activeAddress (\"*Address:* \".[/ppp active get value-name=\"addr\
    ess\" \$activeIndex].\"%0A\")\r\
    \n:local activeCaller (\"*Caller-ID:* \".[/ppp active get value-name=\"cal\
    ler-id\" \$activeIndex].\"%0A\")\r\
    \n:local activeUptime (\"*Uptime:* \".[/ppp active get value-name=\"uptime\
    \" \$activeIndex].\"%0A\")\r\
    \n:local activeService (\"*Uptime:* \".[/ppp active get value-name=\"servi\
    ce\" \$activeIndex].\"%0A\")\r\
    \n:set output (\$output.\$activeUser.\$activeAddress.\$activeCaller.\$acti\
    veUptime.\$ActiveService.\"%0A\")\r\
    \n}\r\
    \n\$send chat=\$chatid text=(\"\$output\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1!=\"password\" and \$param1!=\"profile\" and \$param1!=\"en\
    able\" and \$param1!=\"disable\" and \$param1!=\"delete\" and \$param1!=\"\
    print\") do={\r\
    \n/ppp secret add name=\$param1 password=\$param2 service=pptp profile=\$p\
    aram3 \r\
    \n\$send chat=\$chatid text=(\"\\D8\\AA\\D9\\85\\20\\D8\\A7\\D8\\B6\\D8\\A\
    7\\D9\\81\\D8\\A9\\20\\D8\\A7\\D9\\84\\D8\\AD\\D8\\B3\\D8\\A7\\D8\\A8 %0A\
    \\D8\\A5\\D8\\B3\\D9\\85\\20\\D8\\A7\\D9\\84\\D9\\85\\D8\\B3\\D8\\AA\\D8\\\
    AE\\D8\\AF\\D9\\85: \$param1 %0A\\D9\\83\\D9\\84\\D9\\85\\D8\\A9\\20\\D8\\\
    A7\\D9\\84\\D9\\85\\D8\\B1\\D9\\88\\D8\\B1: \$param2 %0A\\D8\\A7\\D9\\84\\\
    D8\\A8\\D8\\B1\\D9\\88\\D9\\81\\D8\\A7\\D9\\8A\\D9\\84: \$param3 %0ADone..\
    .\") mode=\"Markdown\"\r\
    \n}"
add dont-require-permissions=no name=tg_cmd_ubnt owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local hotspot [:len [/ip hotspot active find]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n:local text \"Ubnt Online:* \$[:len [/ip neighbor find]] *\"\r\
    \n\r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
add dont-require-permissions=no name=tg_cmd_Info owner=admin policy=read \
    source="######################\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n:put \$params\r\
    \n:put \$chatid\r\
    \n:put \$from\r\
    \n\r\
    \n\r\
    \n:local text \"INFO MENU%0A\\\r\
    \n=========================%0A\\\r\
    \n=======BY ABU ZEED=======%0A\\\r\
    \n=========================%0A\\\r\
    \n\r\
    \n/cpu :: \\D9\\85\\D8\\B9\\D9\\84\\D9\\88\\D9\\85\\D8\\A7\\D8\\AA\\20\\D8\
    \\B9\\D8\\A7\\D9\\85\\D8\\A9%0A\\\r\
    \n%0A\\\r\
    \n/ping :: \\D9\\82\\D9\\8A\\D8\\A7\\D8\\B3\\20\\D8\\A8\\D9\\86\\D8\\AC\\2\
    0\\D9\\83\\D9\\88\\D9\\83\\D9\\84%0A\\\r\
    \n%0A\\\r\
    \n/pppActive :: \\D8\\B9\\D8\\AF\\D8\\AF\\20\\D8\\A3\\D9\\83\\D8\\AA\\D9\\\
    81\\20\\D8\\A7\\D9\\84\\D8\\A8\\D8\\B1\\D9\\88\\D8\\AF\\D8\\A8\\D8\\A7\\D9\
    \\86\\D8\\AF%0A\\\r\
    \n%0A\\\r\
    \n/hotspotActive :: \\D8\\B9\\D8\\AF\\D8\\AF\\20\\D8\\A3\\D9\\83\\D8\\AA\\\
    D9\\81\\20\\D8\\A7\\D9\\84\\D9\\87\\D9\\88\\D8\\AA\\D8\\B3\\D8\\A8\\D9\\88\
    \\D8\\AA%0A\\\r\
    \n%0A\\\r\
    \n/ubnt :: \\D8\\B9\\D8\\AF\\D8\\AF\\20\\D8\\A7\\D9\\84\\D9\\82\\D8\\B7\\D\
    8\\B9\\20\\D8\\A7\\D9\\84\\D9\\85\\D8\\AA\\D8\\B5\\D9\\84\\D8\\A9%0A\\\r\
    \n%0A\\\r\
    \n/eHotspot :: \\D8\\AA\\D9\\81\\D8\\B9\\D9\\8A\\D9\\84\\20\\D8\\A7\\D9\\8\
    4\\D9\\87\\D9\\88\\D8\\AA\\D8\\B3\\D8\\A8\\D9\\88\\D8\\AA%0A\\\r\
    \n%0A\\\r\
    \n/dHotspot :: \\D8\\AA\\D8\\B9\\D8\\B7\\D9\\8A\\D9\\84\\20\\D8\\A7\\D9\\8\
    4\\D9\\87\\D9\\88\\D8\\AA\\D8\\B3\\D8\\A8\\D9\\88\\D8\\AA%0A\\\r\
    \n%0A\\\r\
    \n/reboot :: \\D8\\A5\\D8\\B9\\D8\\A7\\D8\\AF\\D8\\A9\\20\\D8\\AA\\D8\\B4\
    \\D8\\BA\\D9\\8A\\D9\\84%0A\\\r\
    \n%0A\\\r\
    \n/p :: \\D9\\84\\D8\\A5\\D8\\B6\\D8\\A7\\D9\\81\\D8\\A9\\20\\D8\\AD\\D8\\\
    B3\\D8\\A7\\D8\\A8\\20\\D8\\A8\\D8\\B1\\D9\\88\\D8\\AF\\D8\\A8\\D8\\A7\\D9\
    \\86\\D8\\AF%0A\\\r\
    \n=======>>>>>>>\\D9\\85\\D8\\AB\\D8\\A7\\D9\\84<<<<<<<=======%0A\\\r\
    \n===>>(/p zeed 123 512K)<<===%0A\\\r\
    \n%0A\\\r\
    \n/h :: \\D9\\84\\D9\\84\\D8\\A5\\D8\\B3\\D8\\AA\\D8\\B9\\D9\\84\\D8\\A7\\\
    D9\\85\\20\\D8\\B9\\D9\\86\\20\\D8\\A8\\D8\\B7\\D8\\A7\\D9\\82\\D8\\A9%0A\
    \\\r\
    \n=======>>>>>>>\\D9\\85\\D8\\AB\\D8\\A7\\D9\\84<<<<<<<=======%0A\\\r\
    \n=======>>>>(/h zeed)<<<<=======%0A\\\r\
    \n\"\r\
    \n\r\
    \n\$send chat=\$chatid text=\$text mode=\"Markdown\"\r\
    \n:return true"
