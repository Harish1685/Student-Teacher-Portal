#using the official node js image
FROM node:18-alpine 

# setting up the workdirectory to /app
WORKDIR /app

#copying the dependencies first
COPY package*.json ./

#installing the dependencies
RUN npm install

#copying the entire application code to the working directory
COPY . . 

#exposing the port
EXPOSE 3500
#command to run the application
CMD [ "node" , "server.js" ]


