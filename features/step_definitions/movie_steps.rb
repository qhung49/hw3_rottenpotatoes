# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create( :title => movie["title"],
                  :release_date => movie["release_date"],
                  :rating => movie["rating"])
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  table = page.find("table#movies").text
  assert table.index(e1) < table.index(e2)
end

Then /I should see sorted (.*)/ do |field|
  start = 0 if field=="title"
  start = 2 if field=="release date"
  count = 0
  list = []
  page.all("table#movies td").each do |element|
    list << element.text if (count%4==start)
    count = count + 1
  end

  list.sort.each do |element|
    prev = list.index(element)-1
    step %{I should see "#{list[prev]}" before "#{element}"} if (prev>=0)
  end
end

Then /I should (not )?see ratings: (.*)/ do |not_see, rating_list|
  table = page.find("table#movies").text
  puts table
  rating_list.split(", ").each do |rating|
    count = 0
    table.split.each do |word|
      count = count+1 if word==rating
      assert count==0 if not_see
    end
    assert count>0 if !not_see
  end
end

Then /I should see no movie/ do
  assert page.all("table#movies td").length == 0
end

Then /I should see all movies/ do
  save_and_open_page
  assert page.all("table#movies td").length == 4*10
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split(", ").each do |rating|
    if uncheck
      step %{I uncheck "ratings_#{rating}"}
    else 
      step %{I check "ratings_#{rating}"}
    end
  end
end

When /I press Refresh/ do
  step %{I press "ratings_submit"}
end