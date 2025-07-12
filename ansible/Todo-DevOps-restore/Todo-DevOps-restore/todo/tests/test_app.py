import django.db
from django.test import TestCase
from django.urls import reverse
import django.utils.timezone
from todo.models import Todo 
from django.utils.timezone import now


#  This test confirms your Todo model is working as expected.
class TodoModelTest(TestCase):
    def test_create_todo(self):
        todo = Todo.objects.create(text='Sample Task')
        self.assertEqual(todo.text, 'Sample Task')
        self.assertIsNotNone(todo.date)

class TodoViewTest(TestCase):
    def test_todo_view_get(self):
        response = self.client.get(reverse('todo'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'index.html')

    def test_todo_view_post(self):
        response = self.client.post(reverse('todo'), {
            'text': 'New Task',
            'date': now()
        })
        self.assertEqual(response.status_code, 302)
        self.assertEqual(Todo.objects.count(), 1)

    def test_remove_todo(self):
        todo = Todo.objects.create(text='Delete Me')
        response = self.client.post(reverse('delete', args=[todo.id]))
        self.assertEqual(response.status_code, 302)
        self.assertEqual(Todo.objects.count(), 0)
