from django.db import models
from django.utils import timezone
# Create your models here.

class Todo(models.Model):
    text = models.CharField(max_length=300)
    date = models.DateTimeField(default=timezone.now)
    
  
    
