# Table of Contents

- [Task](#Task)
- [Create the Service and set the Plugin](#Create-the-Service-and-set-the-Plugin)
- [Create Upstreams and Targets](#Create-Upstreams-and-Targets)
- [Testing](#Testing)





# Task

Create a custom plugin that will send request to a different upstream when it matches header and value.

Requests that match route /local will be proxied to Upstream europe_cluster, except requests that contain the header X-Country=Italy which should be proxied to Upstream italy_cluster

Upstream names are configurable. Header names and values can be hard coded for this exercise.

Extra: Multiple header names and values can be a configurable rule that is matched, for example X-Country=Italy, X-Regione=Abruzzo will go to upstream italy_cluster, but just X-Country=Italy without header X-Regione still goes to europe_cluster





# Create the Service and set the Plugin

    curl -i -X POST \
      --url http://localhost:8001/services/ \
      --data 'name=zilard' \
      --data 'url=http://europe-cluster:8080'

    {"host":"europe-cluster","created_at":1557009183,"connect_timeout":60000,"id":"1d3ef09f-6c3f-4166-8bd6-1e4bc9d37f5a","protocol":"http","name":"zilard","read_timeout":60000,"port":8080,"path":null,"updated_at":1557009183,"retries":5,"write_timeout":60000,"tags":null}


    curl -i -X POST \
      --url http://localhost:8001/services/zilard/routes \
      --data 'paths=/'

    {"next":null,"data":[{"updated_at":1557010296,"created_at":1557010296,"strip_path":true,"snis":null,"hosts":null,"name":null,"methods":null,"sources":null,"preserve_host":false,"regex_priority":0,"service":{"id":"1d3ef09f-6c3f-4166-8bd6-1e4bc9d37f5a"},"paths":["\/"],"destinations":null,"id":"41a13d03-dca3-4a5a-a8b0-c96d488c1e6e","protocols":["http","https"],"tags":null}]}


    curl -i -X POST \
      --url http://localhost:8001/services/zilard/plugins \
      --data 'name=zilard-kong-plugin'

    {"created_at":1557009903,"config":{},"id":"cefac9b7-7484-4274-ab65-366f6a520aeb","service":{"id":"1d3ef09f-6c3f-4166-8bd6-1e4bc9d37f5a"},"name":"zilard-kong-plugin","protocols":["http","https"],"enabled":true,"run_on":"first","consumer":null,"route":null,"tags":null}





# Create Upstreams and Targets

    curl -i -X POST \
      --url http://localhost:8001/upstreams \
      --data 'name=europe-cluster'

    {"created_at":1557010104,"hash_on":"none","id":"f16ad027-0f32-48cb-b5c0-b6de596f9daf","tags":null,"name":"europe-cluster","hash_fallback_header":null,"hash_on_cookie":null,"healthchecks":{"active":{"unhealthy":{"http_statuses":[429,404,500,501,502,503,504,505],"tcp_failures":0,"timeouts":0,"http_failures":0,"interval":0},"type":"http","http_path":"\/","timeout":1,"healthy":{"successes":0,"interval":0,"http_statuses":[200,302]},"https_sni":null,"https_verify_certificate":true,"concurrency":10},"passive":{"unhealthy":{"http_failures":0,"http_statuses":[429,500,503],"tcp_failures":0,"timeouts":0},"healthy":{"http_statuses":[200,201,202,203,204,205,206,207,208,226,300,301,302,303,304,305,306,307,308],"successes":0},"type":"http"}},"hash_on_cookie_path":"\/","hash_fallback":"none","hash_on_header":null,"slots":10000}]}


    curl -i -X POST -H "Content-Type:application/json"  \
      --url http://localhost:8001/upstreams/europe-cluster/targets \
      -d "{ \"target\": \"europe-cluster:8080\" }"

    {"created_at":1557010133.92,"upstream":{"id":"f16ad027-0f32-48cb-b5c0-b6de596f9daf"},"id":"ef9929ef-d147-4966-9bc1-542b36a0f849","target":"europe-cluster:8080","weight":100}




    curl -i -X POST \
      --url http://localhost:8001/upstreams \
      --data 'name=italy-cluster'

    {"created_at":1557010167,"hash_on":"none","id":"ac2ef260-6669-4de9-a3b3-42dd9057d74e","tags":null,"name":"italy-cluster","hash_fallback_header":null,"hash_on_cookie":null,"healthchecks":{"active":{"unhealthy":{"http_statuses":[429,404,500,501,502,503,504,505],"tcp_failures":0,"timeouts":0,"http_failures":0,"interval":0},"type":"http","http_path":"\/","timeout":1,"healthy":{"successes":0,"interval":0,"http_statuses":[200,302]},"https_sni":null,"https_verify_certificate":true,"concurrency":10},"passive":{"unhealthy":{"http_failures":0,"http_statuses":[429,500,503],"tcp_failures":0,"timeouts":0},"healthy":{"http_statuses":[200,201,202,203,204,205,206,207,208,226,300,301,302,303,304,305,306,307,308],"successes":0},"type":"http"}},"hash_on_cookie_path":"\/","hash_fallback":"none","hash_on_header":null,"slots":10000}


    curl -i -X POST -H "Content-Type:application/json"  \
      --url http://localhost:8001/upstreams/italy-cluster/targets \
      -d "{ \"target\": \"italy-cluster:8080\" }"

    {"created_at":1557010215.418,"upstream":{"id":"ac2ef260-6669-4de9-a3b3-42dd9057d74e"},"id":"d207916b-6704-457a-9ba0-3fdb8cc0e140","target":"italy-cluster:8080","weight":100}





# Testing

    curl -i http://localhost:8000/local

    HTTP/1.1 200 OK
    Content-Type: text/html; charset=utf-8
    Content-Length: 26
    Connection: keep-alive
    X-Powered-By: Express
    ETag: W/"1a-7jp7YT2mKQzOL759pZwG39oFcJ0"
    Date: Sun, 05 May 2019 15:48:06 GMT
    X-Kong-Upstream-Latency: 2
    X-Kong-Proxy-Latency: 11
    Via: kong/1.1.1

    Hello from EUROPE_CLUSTER



    curl -i -H "X-Country:Italy" http://localhost:8000

    HTTP/1.1 200 OK
    Content-Type: text/html; charset=utf-8
    Content-Length: 26
    Connection: keep-alive
    X-Powered-By: Express
    ETag: W/"1a-7jp7YT2mKQzOL759pZwG39oFcJ0"
    Date: Sun, 05 May 2019 15:48:11 GMT
    X-Kong-Upstream-Latency: 1
    X-Kong-Proxy-Latency: 1
    Via: kong/1.1.1

    Hello from EUROPE_CLUSTER



    curl -i -H "X-Country:Italy" -H "X-Regione:Abruzzo" http://localhost:8000

    HTTP/1.1 200 OK
    Content-Type: text/html; charset=utf-8
    Content-Length: 25
    Connection: keep-alive
    X-Powered-By: Express
    ETag: W/"19-t/bYiCrLAVxVPGZFFQwjd+LPRjQ"
    Date: Sun, 05 May 2019 15:48:17 GMT
    X-Kong-Upstream-Latency: 1
    X-Kong-Proxy-Latency: 1
    Via: kong/1.1.1

    Hello from ITALY_CLUSTER



