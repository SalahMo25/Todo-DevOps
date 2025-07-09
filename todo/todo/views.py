from django.shortcuts import render, redirect
from .forms import TodoForm
from .models import Todo
# Create your views here.


def todo(request):
    data = Todo.objects.order_by('-date')
    if request.method == 'POST':
        form = TodoForm(request.POST)
        if form.is_valid():
           form.save()
           return redirect('todo')
    
    return render(request, 'index.html', {'form': TodoForm , 'data': data})


def remove(request , id):
    text = Todo.objects.get(id = id)
    text.delete()
    return redirect('todo')