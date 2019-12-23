module ("templates.PiTemplate", thingworx.template.extend)
properties.temperature={baseType="NUMBER", pushType="ALWAYS", value=0}
properties.humidity={baseType="NUMBER", pushType="ALWAYS", value=0}

serviceDefinitions.UpdateTemperatureAndHumidity(
    output { baseType="BOOLEAN", description="" },
    description { "updates properties" }
)

services.UpdateTemperatureAndHumidity = function(me, headers, query, data)
log.trace("[PiTemplate]","########### in UpdateTemperatureAndHumidity#############")
querySensor()
--  if properties are successfully updated, return HTTP 200 code with a true service return value
return 200, true
end



function querySensor()
local f = io.popen("python /home/pi/Desktop/DHT.py 22 4")
local s = f:read("*a")
local output = {}

for match in s:gmatch("([%d%.%+%-]+),?") do
  output[#output + 1] = tonumber(match)
end

 --   set property temperature
log.info("[PiTemplate]",string.format("temperature %.1f",output[1]))
properties.temperature.value = output[1]

--  set property humidity
log.info("[PiTemplate]",string.format("humidity %.1f",output[2]))
properties.humidity.value = output[2]

end

tasks.refreshProperties = function(me)
log.trace("[PiTemplate]","~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ In tasks.refreshProperties~~~~~~~~~~~~~ ")
querySensor()
end

