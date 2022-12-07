# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Volt.Repo.insert!(%Volt.SomeSchema{})
#
# We recommend using the bang functions (insert!, update!
# and so on) as they will fail if something goes wrong.
# Volt.Repo.insert!(%Volt.Accounts.Customer{address: "salam123", cardnumber: "12341234", crypted_password: "$2b$12$hwbm.Vzf5q6hIa6PuZBc1.lzfqdEra3DxFTWHflPT0QqWG7MkhcO.", dateofbirth: ~D[1212-12-12], email: "salam@123.com", name: "Salam"})


alias Volt.Repo
alias Volt.Accounts
alias Volt.Menus
alias Volt.Items
alias Volt.Menus.Menu
alias Volt.Accounts.Customer
alias Volt.Accounts.Courier
alias Volt.Accounts.Restaurant
alias Volt.Items.Item

Repo.delete_all(Customer)
Repo.delete_all(Courier)
Repo.delete_all(Restaurant)
Repo.delete_all(Menu)
Repo.delete_all(Item)

# Customer
Repo.insert! %Customer{
  name: "Customer1",
  email: "customer1@mail.ru",
  crypted_password: Bcrypt.hash_pwd_salt("customer1@mail.ru"),
  dateofbirth: ~D[2000-01-01],
  address: "Staadioni 21, 51008 Tartu",
  cardnumber: "121213323",
  role: "Customer"
}

Repo.insert! %Customer{
  name: "John Doe",
  email: "johndoe@gmail.com",
  crypted_password: Bcrypt.hash_pwd_salt("johndoe@gmail.com"),
  dateofbirth: ~D[2000-10-13],
  address: "Raatuse 22, 51009, Tartu",
  cardnumber: "1111222233334444",
  role: "Customer"
}

# Courier
dummyCourier = Repo.insert! %Courier{
  name: "Dummy",
  email: "dummycourier@mail.ru",
  crypted_password: Bcrypt.hash_pwd_salt("dummycourier@mail.ru"),
  revenue: 0.0,
  likes: 0,
  dislikes: 0,
  status: "Available",
  role: "Courier"
}

Repo.insert! %Courier{
  name: "Courier2",
  email: "courier2@mail.ru",
  crypted_password: Bcrypt.hash_pwd_salt("courier2@mail.ru"),
  revenue: 0.0,
  likes: 0,
  dislikes: 0,
  status: "Available",
  role: "Courier"
}

Repo.insert! %Courier{
  name: "Courier3",
  email: "courier3@mail.ru",
  crypted_password: Bcrypt.hash_pwd_salt("courier3@mail.ru"),
  revenue: 0.0,
  likes: 0,
  dislikes: 0,
  status: "Available",
  role: "Courier"
}

# Restaurant

createdRes1 = Repo.insert! %Restaurant{
  name: "Restaurant1",
  email: "restaurant1@mail.ru",
  crypted_password: Bcrypt.hash_pwd_salt("restaurant1@mail.ru"),
  address: "Narva mnt 10, 51009, Tartu",
  category: "Pizza",
  tags: "fast-food,vegan,american,spicy",

  opens_at: "12:30",
  closes_at: "14:00",
  likes: 20,
  dislikes: 3,
  role: "Restaurant",
  description: "Beatiful Restaurant"
}

createdRes2 = Repo.insert! %Restaurant{
  name: "Restaurant2",
  email: "restaurant2@mail.ru",
  crypted_password: Bcrypt.hash_pwd_salt("restaurant2@mail.ru"),
  address: "Liiva 32, 50303 Tartu",
  category: "Sushi",
  tags: "fast-food,vegan,american,spicy",

  opens_at: "05:00",
  closes_at: "00:00",
  likes: 20,
  dislikes: 3,
  role: "Restaurant",
  description: "Beatiful Restaurant #2"
}

# Menu

# dummyMenu = Repo.insert! %Menu{
#   id: 0,
#   numberOfItems: 0,
#   restaurant_id: dummyRestaurant.id
# }

createdMenu1 = Repo.insert! %Menu{
  numberOfItems: 10,
  restaurant_id: createdRes1.id
}

createdMenu2 = Repo.insert! %Menu{
  numberOfItems: 5,
  restaurant_id: createdRes2.id
}

# Items

# dummyItem1 = Repo.insert! %Item{
#   name: "Dummy item 1",
#   description: "Dummy item 1 description",
#   category: "Food",
#   price: 0.0,
#   menu_id: dummyMenu.id
# }

# dummyItem2 = Repo.insert! %Item{
#   name: "Dummy item 2",
#   description: "Dummy item 2 description",
#   category: "Food",
#   price: 0.0,
#   menu_id: dummyMenu.id
# }

item1 = Repo.insert! %Item{
  name: "Burgeritto",
  description: "Burgeritto description",
  category: "Food",
  price: 12.21,
  menu_id: createdMenu1.id
}

item2 = Repo.insert! %Item{
  name: "BurBur",
  description: "BurBur description",
  category: "Food",
  price: 4.21,
  menu_id: createdMenu2.id
}

item3 = Repo.insert! %Item{
  name: "Pizzarea",
  description: "Pizzarea description",
  category: "Food",
  price: 4.21,
  menu_id: createdMenu2.id
}

item4 = Repo.insert! %Item{
  name: "PizPiz",
  description: "PizPiz description",
  category: "Food",
  price: 4.21,
  menu_id: createdMenu1.id
}

item5 = Repo.insert! %Item{
  name: "Potato",
  description: "Potato description",
  category: "Food",
  price: 12.21,
  menu_id: createdMenu1.id
}

item6 = Repo.insert! %Item{
  name: "Burritto",
  description: "Burritto description",
  category: "Food",
  price: 12.21,
  menu_id: createdMenu2.id
}

item7 = Repo.insert! %Item{
  name: "Tomato",
  description: "Tomato description",
  category: "Food",
  price: 4.21,
  menu_id: createdMenu1.id
}

item8 = Repo.insert! %Item{
  name: "Shah plov",
  description: "Shah description",
  category: "Food",
  price: 3.43,
  menu_id: createdMenu2.id
}

item9 = Repo.insert! %Item{
  name: "Dolma",
  description: "Dolma description",
  category: "Food",
  price: 3.43,
  menu_id: createdMenu2.id
}

item10 = Repo.insert! %Item{
  name: "Smash potato",
  description: "Smash description",
  category: "Food",
  price: 4.21,
  menu_id: createdMenu1.id
}
