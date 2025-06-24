FROM python:3.9-slim

# Install dependencies
RUN pip install selenium pytest pytest-html

# Copy test files into container
COPY . /tests

# Set working directory
WORKDIR /tests

# Run tests when container starts
CMD ["pytest", "--html=report.html"]
