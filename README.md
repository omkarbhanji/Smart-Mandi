# Smart-Mandi
This project provides an end to end solution to the farmers for selling their vegetables at their nearest market with absolute ease. Machine learning is used to provide insights to the farmer, helping the farmer make a right choice. Inventory management and time to time notifications before any incurring any loss to the farmer.


Basic structure of the project:

1. Backend ->
     a. API EndPt. for getting all the nearest market predicted rates
     b. Inventory management CRUD opertions
     c. Live notifications based on avg. rot time for vegetable fetched from internet with buffer to proevent loss. 

3. Frontend
4. ML model -> customized loss function to handle outliners and prediction with confidence level using gaussian/bell curve for probability distribution.

--------------------------------------------------------------------------------------
Project Routes:

1. http://localhost:5000/api/inventory - GET (All inventory records for the farmer who has logged in).
2. http://localhost:5000/api/inventory - POST (Add any new crop to inventory)

3. http://localhost:5000/api/users/register - POST (Register new farmer)
4. http://localhost:5000/api/users/login - POST (login)

--------------------------------------------------------------------------------------

Database schema 

Table name: farmers <br>
schema: <br>
farmer_id |     name     |          email           |         password          |     phone      |    location    |    state    |         created_at         |         updated_at         | latitude  | longitude

Table name: inventory <br>
schema: <br>

 inventory_id | farmer_id | crop_name | quantity | unit | harvest_date | expiry_date | remaining_quantity |  status   |         created_at         |         updated_at
