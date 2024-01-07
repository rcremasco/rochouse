influxdb2

select data:

from(bucket: "ha/autogen")
  |> range(start:  2020-02-01, stop: 2023-12-03 )
  |> filter(fn: (r) => r["_measurement"] == "°C")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "temperature_39")



copy data:
import "experimental"


from(bucket: "ha/autogen")
  |> range(start:  2020-02-01, stop: 2023-12-03 )
  |> filter(fn: (r) => r["_measurement"] == "°C")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "temperature_39")
  |> experimental.set(o: {entity_id: "temperature_185", friendly_name: "Tempo.bagno sopra_new test" })
  |> to(bucket: "ha/autogen")
