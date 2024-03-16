from kivy.app import App
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.graphics import Color, RoundedRectangle
from kivy.uix.screenmanager import ScreenManager, Screen, CardTransition


class RoundedBoxWidget(FloatLayout):
    def __init__(self, **kwargs):
        super(RoundedBoxWidget, self).__init__(**kwargs)
        with self.canvas:
            Color(0.7, 0.7, 0.7)
            self.rounded_rect = RoundedRectangle(pos=self.pos, size=self.size, radius=[20])
            self.bind(pos=self.update_rounded_rect, size=self.update_rounded_rect)

        self.username_label = Label(text='Username', size_hint=(None, None), size=(100, 30), pos=(285, 370))
        self.add_widget(self.username_label)
        self.username = TextInput(multiline=False, size_hint=(None, None), size=(200, 30), pos_hint={'center_x': 0.5, 'center_y': 0.7})
        self.add_widget(self.username)

        self.password_label = Label(text='Password', size_hint=(None, None), size=(100, 30), pos=(285, 290))
        self.add_widget(self.password_label)
        self.password = TextInput(password=True, multiline=False, size_hint=(None, None), size=(200, 30), pos_hint={'center_x': 0.5, 'center_y': 0.4})
        self.add_widget(self.password)

    def update_rounded_rect(self, instance, value):
        self.rounded_rect.pos = self.pos
        self.rounded_rect.size = self.size


class LoginScreen(Screen):
    def __init__(self, instance=None, **kwargs):
        super(LoginScreen, self).__init__(**kwargs)
        self.instance = instance
         
        self.rounded_box = RoundedBoxWidget(size_hint=(None, None), size=(250, 250), pos_hint={'center_x': 0.5, 'center_y': 0.5})
        self.add_widget(self.rounded_box)

        self.login_button = Button(text='Login', size_hint=(None, .15), size=(100, 50), pos=(345, 190))
        self.login_button.bind(on_press=self.login)
        self.rounded_box.add_widget(self.login_button)

    def login(self, instance):
        username = self.rounded_box.username.text
        password = self.rounded_box.password.text

        if (username == "guest" and password == "trial"): 
            from dashboard import HeartCheck
            heart_check = HeartCheck(name="heart_check")

            if "heart_check" not in self.instance.screen_names:
                self.instance.add_widget(heart_check)

            self.instance.current = "heart_check"
        else:
            self.add_widget(Label(text="Login failure! Try again.", color=(1, 0, 0, 1), font_size=12, pos=(0, -55)))


class HeartCheckApplication(App):
    def build(self):
        sm = ScreenManager(transition=CardTransition())
        loginscreen = LoginScreen(name="loginscreen", instance=sm)

        sm.add_widget(loginscreen)
        sm.current = "loginscreen"

        return sm

if __name__ == '__main__':
    HeartCheckApplication().run()
