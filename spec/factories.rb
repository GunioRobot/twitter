Factory.define :user do |user|
  user.name			"Kegan Quimby"
  user.email			"kegan.quimby@gmail.com"
  user.password			"foobar"
  user.password_confirmation	"foobar"

end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :micropost do |micropost|
  micropost.content "hello world, welcome"
  micropost.association :user
end
