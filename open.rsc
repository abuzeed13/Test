
/system script
add dont-require-permissions=no name=tg_cmd_j owner=admin policy=read,romon source="##############\
    ########\r\
    \n####DEV BY ABU ZEED####\r\
    \n######################\r\
    \n\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local param1 [:pick \$params 0 [:find \$params \" \"]]\r\
    \n:local param2 [:pick \$params ([:find \$params \" \"]+1) [:len \$params]]\r\
    \n:local param3 [:pick [:pick \$params ([:find \$params \" \"]+1) [:len \$params]] ([:find [:p\
    ick \$params ([:find \$params \" \"]+1) [:len \$params]] \" \"]+1) [:len [:pick \$params ([:fi\
    nd \$params \" \"]+1) [:len \$params]]]]\r\
    \n:if ([:len [:find \$param2 \" \"]]>0) do={\r\
    \n\t:set param2 [:pick [:pick \$params ([:find \$params \" \"]+1) [:len \$params]] 0 [:find [:\
    pick \$params ([:find \$params \" \"]+1) [:len \$params]] \" \"]]\r\
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
    \n/ip hot user remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User Hotspot: \$param2 Berhasil dihapus\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"disable\") do={\r\
    \n/ip hot user disable [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User Hotspot: \$param2 Disable\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"enable\") do={\r\
    \n/ip hot user enable [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User Hotspot: \$param2 Enable\") mode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"password\") do={\r\
    \n/ip hot user set password=\$param3 [find name=\$param2]\r\
    \n/ip hot active remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User Hotspot: \$param2 pasword diganti menjadi \$param3...\") m\
    ode=\"Markdown\"\r\
    \n}\r\
    \n:if (\$param1=\"profile\") do={\r\
    \n/ip hot user set profile=\$param3 [find name=\$param2]\r\
    \n/ip hot active remove [find name=\$param2]\r\
    \n\$send chat=\$chatid text=(\"User Hotspot: \$param2 profile diganti menjadi \$param3...\") m\
    ode=\"Markdown\"\r\
    \n}\r\
    \n\r\
    \n\r\
    \n:if (\$param1!=\"password\" and \$param1!=\"profile\" and \$param1!=\"enable\" and \$param1!\
    =\"disable\" and \$param1!=\"delete\" and \$param1!=\"print\") do={\r\
    \n/ip hot user add name=\$param1 password=\$param2 profile=\$param3 \r\
    \n\$send chat=\$chatid text=(\"\\D8\\AA\\D9\\85\\20\\D8\\A7\\D8\\B6\\D8\\A7\\D9\\81\\D8\\A9\\2\
    0\\D8\\A7\\D9\\84\\D8\\AD\\D8\\B3\\D8\\A7\\D8\\A8 %0A\\D8\\A5\\D8\\B3\\D9\\85\\20\\D8\\A7\\D9\
    \\84\\D9\\85\\D8\\B3\\D8\\AA\\D8\\AE\\D8\\AF\\D9\\85: \$param1 %0A\\D9\\83\\D9\\84\\D9\\85\\D8\
    \\A9\\20\\D8\\A7\\D9\\84\\D9\\85\\D8\\B1\\D9\\88\\D8\\B1: \$param2 %0A\\D8\\A7\\D9\\84\\D8\\A8\
    \\D8\\B1\\D9\\88\\D9\\81\\D8\\A7\\D9\\8A\\D9\\84: \$param3 %0ADone...\") mode=\"Markdown\"\r\
    \n}\r\
    \n\r\
    \n"