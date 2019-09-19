extends Node

onready var Auth = HTTPRequest.new()
onready var Database = Node.new()
onready var Firestore = Node.new()
onready var Storage = HTTPRequest.new()

onready var config = {
    "apiKey": "AIzaSyBKSj4xVb0WWyAgQefb2t-Pr2p2mL5mJgc",
    "authDomain": "avl-battleship.firebaseapp.com",
    "databaseURL": "https://avl-battleship.firebaseio.com",
    "projectId": "avl-battleship",
    "storageBucket": "",
    "messagingSenderId": "363038745464",
    "appId": "1:363038745464:web:9df7cb349257aee360de8d"
}

func _ready():
    Auth.set_script(preload("res://addons/GDFirebase/FirebaseAuth.gd"))
    Database.set_script(preload("res://addons/GDFirebase/FirebaseDatabase.gd"))
    Firestore.set_script(preload("res://addons/GDFirebase/FirebaseFirestore.gd"))
    Storage.set_script(preload("res://addons/GDFirebase/FirebaseStorage.gd"))
    Auth.set_config(config)
    Database.set_config(config)
    Firestore.set_config(config)
    Storage.set_config(config)
    add_child(Auth)
    add_child(Database)
    add_child(Firestore)
    add_child(Storage)
    Auth.connect("login_succeeded", Database, "_on_FirebaseAuth_login_succeeded")
    Auth.connect("login_succeeded", Firestore, "_on_FirebaseAuth_login_succeeded")
    Auth.connect("login_succeeded", Storage, "_on_FirebaseAuth_login_succeeded")