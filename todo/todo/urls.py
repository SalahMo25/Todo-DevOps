from django.urls import path
from . import views
from django.views.generic import RedirectView
urlpatterns = [
    path('', RedirectView.as_view(url='todo', permanent=False)), 
    path('todo', views.todo , name='todo'  ),
    path('delete/<int:id>', views.remove , name='delete'  ),
]
