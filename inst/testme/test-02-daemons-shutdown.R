mirai::daemons(2)
print(mirai::status())
mirai::daemons(0)
print(mirai::status())

## Give daemons a chance to shutdown
Sys.sleep(10)
