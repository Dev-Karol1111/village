extends Resource

class_name People

var name := "Name"
var age := 0
var gender := "male"
var statistics := {"strenght" : 0, "skill" : 0, "flair" : 0}
var work := ""

var male_names := ["Michael", "James", "John", "Robert", "David","William", "Thomas", "Daniel", "Matthew", "Andrew","Christopher", "Joseph", "Brian", "Kevin", "Steven","George", "Edward", "Paul", "Mark", "Anthony","Benjamin", "Samuel", "Charles", "Timothy", "Jason","Alex", "Nathan", "Jonathan", "Scott", "Aaron","Oliver", "Henry", "Luke", "Logan", "Ethan","Jacob", "Owen", "Caleb", "Tyler", "Jack","Adam", "Patrick", "Gregory", "Sean", "Kyle","Zachary", "Leo", "Isaac", "Jordan", "Cole"]
var female_names := ["Emma", "Olivia", "Sophia", "Ava", "Isabella","Mia", "Charlotte", "Amelia", "Harper", "Ella","Grace", "Chloe", "Abigail", "Lily", "Emily","Madison", "Elizabeth", "Scarlett", "Hannah", "Aria","Natalie", "Samantha", "Zoe", "Victoria", "Lucy","Evelyn", "Nora", "Ellie", "Aubrey", "Stella","Layla", "Riley", "Penelope", "Lillian", "Addison","Brooklyn", "Savannah", "Hazel", "Violet", "Aurora","Alice", "Claire", "Bella", "Maya", "Elena","Paisley", "Caroline", "Anna", "Sadie", "Kennedy"]

func generate_data(type: String, preset_name:= "", preset_age:=0, preset_gender:="", preset_statistics={"strenght" : 0, "skill" : 0, "flair" : 0}):
	gender = ["male", "female"].pick_random()
	name = get("%s_names" % gender).pick_random()
	if type == "child":
		age = randf_range(4,14)	
	elif type == "adult":
		age = randf_range(20,45)
	elif type == "greybeard":
		age = randf_range(65, 70)		
	