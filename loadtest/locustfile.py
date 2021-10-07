from locust import HttpUser, task


class HelloCloudUser(HttpUser):

  @task
  def hello_cloud(self):
    self.client.get('/')
    self.client.get('/api/')
