@echo off

sc config dhcp start= disabled

sc config defragsvc start= disabled

sc config AudioSrv start= disabled

sc config AudioEndpointBuilder start= disabled

sc config WSearch start= disabled

sc config fdPHost start= disabled

sc config PNRPsvc start= disabled

sc config p2psvc start= disabled

sc config p2pimsvc start= disabled

sc config xenlite start= disabled
