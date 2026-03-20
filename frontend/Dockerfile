# ----- STAGE - 1 (BUILD REACT APP)--------------
FROM node:18-alpine as builder

#setting up the work directory to /app
WORKDIR /app

# copying the dependencies first
COPY package*json ./

# installing the dependencies
RUN npm install

#copying the entire code in the work directory
COPY . .

#building the application
RUN npm run build

# --------STAGE -2 (RUNNING THE APPLICATION)---------
FROM nginx:1.25.3-alpine as runner

#copying the build artifacts from previous stage
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

#exposing the port
EXPOSE 80

CMD [ "nginx" , "-g" , "daemon off;" ]