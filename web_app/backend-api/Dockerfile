# Use official Node.js base image (small & secure)
FROM node:18-alpine

#Set the working directory in the container
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install


COPY . .

EXPOSE 3000
# Run the app using npm
CMD ["npm", "start"]


