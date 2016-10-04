--Configure relay ouutput pins, pins are floating and relay opto needs ground to be activated. So pins are kept high on startup.
Relay1 = 3
Relay2 = 4
gpio.mode(Relay1, gpio.OUTPUT)
gpio.write(Relay1, gpio.LOW);
gpio.mode(Relay2, gpio.OUTPUT)
gpio.write(Relay2, gpio.LOW);

wifi.setmode(wifi.STATION) --Set network mode to station to connect it to wifi router. You can also set it to AP to make it a access point allowing connection from other wifi devices.

--Set a static ip so its easy to access
--cfg = {
--    ip="192.168.2.87",
--    netmask="255.255.255.0",
--    gateway="192.168.2.15"
--  }
--wifi.sta.setip(cfg)

--Your router wifi network's SSID and password
wifi.sta.config("YOURNETWOR","YOURPASSWORD")
--Automatically connect to network after disconnection
wifi.sta.autoconnect(1)
print ("\r\n")
--Print network ip address on UART to confirm that network is connected
print(wifi.sta.getip())
--Create server and send html data, process request from html for relay on/off.
srv=net.createServer(net.TCP)
srv:listen(80,function(conn) --change port number if required. Provides flexibility when controlling through internet.
    conn:on("receive", function(client,request)
        local html_buffer = "";
		
		
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(Relay1, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
              gpio.write(Relay1, gpio.LOW);
        elseif(_GET.pin == "ON2")then
              gpio.write(Relay2, gpio.HIGH);
        elseif(_GET.pin == "OFF2")then
              gpio.write(Relay2, gpio.LOW);
        end
        
        local gpioRead = "" ..  gpio.read(Relay1);
		html_buffer = html_buffer.."HTTP/1.1 200 OK\n\n";
		html_buffer = html_buffer.. gpioRead;

        --Buffer is sent in smaller chunks as due to limited memory ESP8266 cannot handle more than 1460 bytes of data.
		client:send(html_buffer);
        client:close();
        collectgarbage();
    end)
end)
