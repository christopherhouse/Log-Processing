using Newtonsoft.Json;

namespace LogProcessing.Functions.Models
{
    public class RawLogEntry
    {
        [JsonProperty("SOURCE")]
        public string Source { get; set; }

        [JsonProperty("PROGRAM")]
        public string Program { get; set; }

        [JsonProperty("PRIORITY")]
        public string Priority { get; set; }

        [JsonProperty("PID")]
        public string ProcessId { get; set; }

        [JsonProperty("MESSAGE")]
        public string Message { get; set; }

        [JsonProperty("LEGACY_MSGHDR")]
        public string LegacyMessageHeader { get; set; }

        [JsonProperty("HOST_FROM")]
        public string From { get; set; }

        [JsonProperty("HOST")]
        public string Host { get; set; }

        [JsonProperty("FACILITY")]
        public string Facility { get; set; }

        [JsonProperty("@t")]
        public string Time { get; set; }

        [JsonProperty("@m")]
        public string RawMessage { get; set; }
    }
}

/*
{"SOURCE":"s_network_udp",
"PROGRAM":"",
"PRIORITY":"notice",
"PID":"WAN_LOCAL-D-2000"
,"MESSAGE":"DESCR=\"WAN DROPS\"
IN=eth8
OUT= MAC=ff:ff:ff:ff:ff:ff:02:cc:c0:a8:cb:05:08:00 
SRC=107.4.201.81 DST=255.255.255.255 
LEN=195 
TOS=00
PREC=0x20 
TTL=64 
ID=0
DF PROTO=UDP 
SPT=2190 
DPT=2190 
LEN=175 
MARK=380000 ",
"LEGACY_MSGHDR":"[WAN_LOCAL-D-2000] ",
"HOST_FROM":"10.0.0.1",
"HOST":"10.0.0.1",
"FACILITY":"user"
,"@t":"2023-01-03T14:53:28+00:00",
"@m":"DESCR=\"WAN DROPS\" IN=eth8 OUT= MAC=ff:ff:ff:ff:ff:ff:02:cc:c0:a8:cb:05:08:00 SRC=107.4.201.81 DST=255.255.255.255 LEN=195 TOS=00 PREC=0x20 TTL=64 ID=0 DF PROTO=UDP SPT=2190 DPT=2190 LEN=175 MARK=380000 "}
*/