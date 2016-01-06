// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
 
Parse.Cloud.define("seedTestUsers", function(request, response) {
    var userDicts = [{"email": "amy@bondvoyage.com", "firstName": "Amy", "interests": randomInterests(), password: "test", birthYear: 2016 - 21, gender: "female"},
            {"email": "bobby@bondvoyage.com", "firstName": "Bobby", "interests":  randomInterests(), password: "test", birthYear: 2016 - 32, gender: "male"},
            {"email": "chris@bondvoyage.com", "firstName": "Chris", "interests":  randomInterests(), password: "test", birthYear: 2016 - 29, gender: "male"},
            {"email": "danielle@bondvoyage.com", "firstName": "Danielle", "interests":  randomInterests(), password: "test", birthYear: 2016 - 45, gender: "female"},
            {"email": "erica@bondvoyage.com", "firstName": "Erica", "interests":  randomInterests(), password: "test", birthYear: 2016 - 28, gender: "female"},
            {"email": "fredson@bondvoyage.com", "firstName": "Fredson", "interests": randomInterests(), password: "test", birthYear: 2016 - 32, gender: "male"},
            {"email": "ginger@bondvoyage.com", "firstName": "Ginger", "interests":  randomInterests(), password: "test", birthYear: 2016 - 26, gender: "female"},
            {"email": "henry@bondvoyage.com", "firstName": "Henry", "interests":  randomInterests(), password: "test", birthYear: 2016 - 14, gender: "male"},
            {"email": "irene@bondvoyage.com", "firstName": "Irene", "interests":  randomInterests(), password: "test", birthYear: 2016 - 22, gender: "female"},
            {"email": "jake@bondvoyage.com", "firstName": "Jake", "interests": randomInterests(), password: "test", birthYear: 2016 - 42, gender: "male"},
            {"email": "kyle@bondvoyage.com", "firstName": "Kyle", "interests": randomInterests(), password: "test", birthYear: 2016 - 18, gender: "male"}
            ]
    var total = 0

    Parse.Cloud.useMasterKey()

    for(var i=0; i < userDicts.length; i++) {
        var dict = userDicts[i]
        var user = new Parse.User(dict)
        user.set("username", user.get("email"))
 
        // try to create demo user.
        console.log("creating user for " + dict["email"] + " email " + user.get("username") + " " + user.get("email") + " " + user.get("password"))
        user.signUp(null, {
            success: function(createdUser) {
                total = total + 1
                if (total == userDicts.length) {
                    response.success("seedTestUsers completed with " + total + " new users created")
                }
            },
            error: function(user, error) {
                total = total + 1
                if (total == userDicts.length) {
                    response.success("seedTestUsers completed with " + total + " new users created")
                }
            }
        })
    }
});
 
Parse.Cloud.define("seedTestEvents", function(request, response) {
    var dicts = [{"name": "Coffee on the Esplanade", "description": "Drink coffee with me. Enjoy the outdoors.", "interests": ["coffee", "tea", "outdoors"]},
            {"name": "Boston Bar crawl", "description": "Meet up at the Crossroads, go down Boylston St until we get hammered", "interests": ["beer", "wine", "liquor", "rock music"]},
            {"name": "Sports day on the Commons", "description": "Let's enjoy the weather and play some pick up sports", "interests": ["basketball", "taekwondo", "surfing", "hiking", "soccer", "frisbee", "ultimate"]},
            {"name": "Clubbing and Dancing", "description": "I don't even know what clubs still exist in Boston", "interests": ["beer", "liquor", "wine", "dancing", "rock music", "hiphop"]},
            {"name": "Game night", "description": "Get some beer and pizza, stay in and chill. Netflix?", "interests": ["beer", "liquor", "wine", "movies", "video games"]}
            ]
    var total = 0
 
    Parse.Cloud.useMasterKey()
     
    var query = new Parse.Query(Parse.User)
    query.find().then(function(allUsers) {
        var Event = Parse.Object.extend("Event")
        for(var i=0; i < dicts.length; i++) {
            var dict = dicts[i]
            console.log("creating event " + dict["name"])
 
            var newEvent = new Event(dict)
 
            var relation = newEvent.relation("users")
            var randos = randomUsers(allUsers)
            for (var j=0; j<randos.length; j++) {
                var user = randos[j]
                relation.add(user)
            }
            newEvent.save().then(
                function(object) {
                    total = total + 1
                    if (total == dicts.length) {
                        response.success("seedTestEvents completed with " + total + " new events created")
                    }
                },
                function(error) {
                    total = total + 1
                    if (total == dicts.length) {
                        response.success("seedTestEvents completed with error, " + total + " new events created")
                    }
                }
            )
        }
    }, function(error) {
        // ignore error
        console.log("could not load all users for event")
        response.success()
    });
});
 
Parse.Cloud.afterSave("Event", function(request,response){
    // add random users to Event for test
    Parse.Cloud.useMasterKey()
 
    // load all users
    var relation = request.object.relation("users")
    relation.query().find({
        success: function(results) {
            console.log("found " + results.length + " users for event")
            var total = 0
            for (var j=0; j<results.length; j++) {
                var user = results[j]
                var userRelation = user.relation("events")
                userRelation.add(request.object)
                user.save().then(
                    function(object) {
                        console.log("user added event")
                        total = total + 1
                        if (total == results.length) {
                            response.success("users updated with new event: " + total)
                        }
                    }, 
                    function(error) {
                        console.log("user could not add event " + error.message)
                        total = total + 1
                        if (total == results.length) {
                            response.error("ignoring error for adding event relations to users")
                        }
                    }
                )
            }
        },
        error: function(error) {
            console.log("could not generate random users for event")
            // ignore error
            response.error("could not generate random users for event")
        }
    })
})
 
var randomInterests = function() {
    var interests = ["coffee", "tea", "movies", "video games", "taekwondo", "surfing", "beer", "wine", "liquor", "modern art", "dancing", "classical music", "rock music", "hiphop", "basketball", "hiking", "painting", "books", "web design", "hacking", "cooking", "soccer", "frisbee", "ultimate"]
    var total = Math.floor(Math.random() * interests.length)
    var newInterests = []
    do {
        var index = Math.floor(Math.random() * interests.length)
        if (newInterests.indexOf(interests[index]) == -1) {
            newInterests.push(interests[index])
        }
    } while (newInterests.length < total)
    return newInterests
}
 
var randomUsers = function(users) {
    var total = Math.floor(Math.random() * users.length)
    var newUsers = []
    do {
        var index = Math.floor(Math.random() * users.length)
        if (newUsers.indexOf(users[index]) == -1) {
            newUsers.push(users[index])
        }
    } while (newUsers.length < total)
    return newUsers
}
 
var toLowerCase = function(w) { 
    return w.toLowerCase(); 
};
 
Parse.Cloud.define("queryUsers", function(request, response) {
    var interests = request.params.interests
 
    var genderOptions = request.params.gender
    if (genderOptions != undefined) {
        if (genderOptions.length == 0) {
            genderOptions = ["male", "female"]
        }
        // TODO: error if gender options are invalid. or, ignore?
    }
 
    var ageOptions = request.params.age // can be a single number or a range
    if (ageOptions != undefined) {
        if (ageOptions.length == 0) {
            ageOptions = [0, 99]
        }
        else if (ageOptions.length == 1) {
            var age = ageOptions[0]
            ageOptions = [age - 2, age + 2]
        }
        // TODO: error if age range is invalid
    }
 
    // only relevant for events or groups...not search results
    var numberOptions = request.params.number // can be a single number or a range
    if (numberOptions != undefined) {
        if (numberOptions.length == 0) {
            numberOptions = [99]
        }
        var max = numberOptions[0]
        if (numberOptions.length > 1) {
            max = numberOptions[1]
        }
        // TODO: error if number range is invalid
    }
 
    interests = interests.map(toLowerCase)
    console.log("searching for " + interests.length + " interests: " + interests)

    var query = new Parse.Query(Parse.User)
    query.containsAll("interests", interests)

    if (genderOptions != undefined) {
        query.containedIn("gender", genderOptions)
    }
    if (ageOptions != undefined) {
        query.greaterThanOrEqualTo("age", ageOptions[0])
        query.lessThanOrEqualTo("age", ageOptions[1])
    }

    console.log("calling query.find")
    query.find({
        success: function(users) {
            console.log("Results count " + users.length)
            var resultDict = {"interests": interests, "users": users}
            response.success(resultDict)
        },
        error: function(error) {
            console.log("query failed: error " + error)
            response.error(error)
        }         
    })
});