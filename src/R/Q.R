library(jsonlite)
library(rmongodb)

cat('\014')
parseMap <- function (mapJSON) ({
    
    map <- fromJSON(mapJSON)
    Qmap <- NA
    class(Qmap) = "Qmap"
    
    parseNode <- function(idea) ({
        parseNode(idea$ideas)
    })
    
    Qmap <- parseNode(map)
    
    map
})


qbase <- mongo.create() #Local

mapJSON <- '{"title":"Queries","id":1,"formatVersion":2,"ideas":{"1":{"title":"A","id":2},"11":{"title":"B","id":3},"21":{"title":"C","id":4,"ideas":{"1":{"title":"I","id":5},"2":{"title":"II","id":6},"3":{"title":"III","id":7}}}}}'
print(prettify(unbox(mapJSON)))

map <- parseMap(mapJSON)

#mongo.insert(qbase,'qbase.test',map)