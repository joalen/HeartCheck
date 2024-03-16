import threading, json, os
from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.graphics import Rectangle, Color, RoundedRectangle
from kivy.core.window import Window
from kivy.uix.image import Image
from kivy.uix.button import Button
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.gridlayout import GridLayout
from kivy.core.text import LabelBase
from kivy.uix.popup import Popup
from kivy.uix.dropdown import DropDown
from kivy.uix.textinput import TextInput
from kivy.uix.image import AsyncImage
from classifier import risk_assessment
from kivy.uix.screenmanager import Screen

# Read the configuration file of the user
with open('userdata.json', 'r') as jobj: 
    userdata = json.load(jobj)

# Define instantiated Dashboard
appInstance = None

# Define customs
LabelBase.register(name='Alatsi', fn_regular=os.getcwd() + '\\Assets\\Alatsi-Regular.ttf')

""" 
Responsible for creating the SimulationThread() that adds concurrency for other GUI interactions

Consists of...
 - stop_event = the actual thread
 - result = the result from the risk_assessment model 
 - finished = indicates if the thread is complete 
 - runnning = indicates if the thread is currently active
"""
class SimulationThread(threading.Thread): 
    def __init__(self):
        super(SimulationThread, self).__init__()
        self.stop_event = threading.Event()
        self.result = None 
        self.finished = False 
        self.running = False
    def run(self):
        self.running = True
        self.result = risk_assessment()
        self.stop_event.set()
        self.running = False
        self.finished = True 
    def stop(self):
        self.running = False
        self.finished = True
        self.stop_event.set()

"""
ClickableImage is an invisible button that gives full transparency of the button to blend in with the GUI while registering user events
"""
class ClickableImage(AsyncImage):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def on_touch_down(self, touch):
        if self.collide_point(*touch.pos):
            appInstance.edit_value_popup(self.title, self.attrib)
            return True
        return super().on_touch_down(touch)


"""
PillButton is a class derived from the Kivy Button Class that allows a rounded button to form. In the HeartCheck project, only two is instantiated here
"""
class PillButton(Button):
    def __init__(self, icon='', **kwargs):
        super(PillButton, self).__init__(**kwargs)
        self.background_normal = ''
        self.background_color = (1, 1, 1, 0)
        self.image = Image(source=icon)
        self.add_widget(self.image)
        self.bind(size=self._update_graphics, pos=self._update_graphics)

    def _update_graphics(self, *args):
        self.canvas.before.clear()
        with self.canvas.before:
            Color(1, 1, 1, 1)
            size = self.size
            RoundedRectangle(pos=self.pos, size=size, radius=[size[1] / 2])
        self.image.pos = ((self.center_x - self.image.width / 1.5) - 60, (self.center_y - self.image.height / 1.5) - 30)
        self.image.size = self.size

"""
RoundedBox is a class derived from Kivy's Widget class. In the HeartCheck program, 15 is needed with 1 that dynamically updates!
"""
class RoundedBox(Widget):
    def __init__(self, text_content=(), color=Color(1, 1, 1, 1,), corner_radius=0, editoffset=None, font_size=(48, 20, 18), font_offset=([40, 110], [0, 75], [155, -20]), **kwargs):
        super(RoundedBox, self).__init__(**kwargs)
        self.corner_radius = corner_radius
        self.color = color
        self.font_size = font_size if font_size is not None else (48, 20, 18)
        self.font_offset = font_offset if font_offset is not None else ([40, 110], [0, 75], [155, -20])

        with self.canvas:
            Color(*color.rgb) 
            self.rect = RoundedRectangle(pos=self.pos, size=self.size, radius=[self.corner_radius])
        
        self.text_labels = (Label(text=text_content[0], padding=(12, 0, 0, 0), font_name="Alatsi", font_size=self.font_size[0], pos=(self.pos[0] + self.font_offset[0][0], self.pos[1] + self.font_offset[0][1])), Label(text=text_content[1], padding=(12, 0, 0, 0), font_size=self.font_size[1], pos=(self.pos[0] + self.font_offset[1][0], self.pos[1] + self.font_offset[1][1])), Label(text=text_content[2], font_size=self.font_size[2], pos=(self.pos[0] + self.font_offset[2][0], self.pos[1] + self.font_offset[2][1])))

        for labl_obj in self.text_labels: 
            self.add_widget(labl_obj)
        
        if (editoffset is not None):
            description_mapping = {"Chest Pain": "cp", "Cholesterol": "chol", "Resting Blood Pressure": "trestbps", "Fasting Blood Sugar": "fbs", "Resting ECG": "restecg", "Max Heart Rate": "thalch", "Exercise Induced Angina": "exang", "ST Depression": "oldpeak", "ST Slope": "slope", "Major Vessel Count": "ca", "Thalassemia": "thal", "Ejection Fraction": "ef", "Brain Natriuretic Peptide": "bnp", "C-Reactive Protein": "crp", "Angiographic Disease": "num"}
            editBtn = ClickableImage(source=os.getcwd() + "\\Assets\\edit.png", size=(20, 20), pos=(self.pos[0] + 245, self.pos[1] + 180))
            editBtn.title = text_content[2]
            editBtn.attrib = description_mapping[text_content[2]]
            self.add_widget(editBtn)

"""
VerticalBar derives from Kivy's Widget class that is responsible for establishing a GUI element at the top of the window for a polished finish
"""
class VerticalBar(Widget):
    def __init__(self, **kwargs):
        super(VerticalBar, self).__init__(**kwargs)
        self.orientation = 'vertical'
        
        with self.canvas:
            Color(0.17647058823529413, 0.17647058823529413, 0.17647058823529413, 1)
            self.rect = Rectangle(size=(277, 1011), pos=(0, Window.height - 1060))

"""
HorizontalBar derives from Kivy's Widget class that is responsible for establishing the menu bar in the dashboard
"""
class HorizontalBar(Widget):
    def __init__(self, **kwargs):
        super(HorizontalBar, self).__init__(**kwargs)
        
        with self.canvas:
            Color(0, 0, 0, 1)
            self.rect = Rectangle(pos=(0, Window.height - 50), size=(Window.width, 50))

        self.image = Image(source=os.getcwd() + '\\Assets\\image_2024-03-12_002701582.png')
        self.add_widget(self.image)
        self.bind(pos=self.update_image_pos, size=self.update_image_size)

    def update_image_pos(self, instance, value):
        self.image.pos = value

    def update_image_size(self, instance, value):
        self.image.size = value

    def on_size(self, *args):
        self.rect.size = (Window.width, 50)
        self.rect.pos = (0, Window.height - 50)
        self.image.pos = (-900, 485)
        self.image.size = (1, 1)


"""
The main program dashboard
"""
roundbox = []
class HeartCheck(Screen):
    """
    Constants defined for the main dashboard
    """
    text_content_vector = [ 
        [("{}".format(userdata["trestbps"]), "mmHg", "Resting Blood Pressure"), ("{}".format(userdata["chol"]), "mg/dl", "Cholesterol"), ("{}".format(userdata["thalch"]), "bpm", "Max Heart Rate"), ("{:+}".format(userdata["oldpeak"]) if userdata["oldpeak"] >= 0 else "{}".format(userdata["oldpeak"]), "mm", "ST Depression"), ({0: "Downsloping", 1: "Flat", 2: "Upsloping"}.get(userdata["slope"], "Unknown"), "", "ST Slope")], 
        [("{}".format(userdata["fbs"]), "mg/dl", "Fasting Blood Sugar"), ({0: "LV Hypertrophy", 1: "Normal", 2: "ST-T Abnormality"}.get(userdata["restecg"], "Unknown"), "", "Resting ECG"), ("Yes" if userdata["exang"] else "No", "", "Exercise Induced Angina"), ("{}".format(userdata["ca"]), "", "Major Vessel Count"), ("{}".format(userdata["crp"]), "mg/L", "C-Reactive Protein")], 
        [({0: "Asymptomatic", 1: "Atypical Angina", 2: "Non-anginal", 3: "Typical Angina"}.get(userdata["cp"], "Unknown"), "", "Chest Pain"), ({0: "Fixed Defect", 1: "Normal", 2: "Reversible Defect"}.get(userdata["thal"], "Unknown"), "", "Thalassemia"), ("{}".format(userdata["ef"]), "", "Ejection Fraction"), ("{}".format(userdata["bnp"]), "pg/mL", "Brain Natriuretic Peptide"), ("N/A", "", "Angiographic Disease")] 
    ]
            
    text_size_vector = [
        [None, None, None, None, (36, 20, 18)],
        [None, (36, 20, 18), None, None, None],
        [(36, 20, 18), (36, 20, 18), None, None, None]
    ]

    text_offset_vector = [
        [([0, 110], [0, 75], [125, -20]), ([6, 110], [0, 75], [155, -20]), ([14, 110], [0, 75], [145, -20]), ([0, 110], [0, 75], [145, -20]), ([65, 110], [0, 75], [135, -20])],
        [([30, 110], [0, 75], [135, -20]), ([80, 110], [0, 75], [135, -20]), ([5, 110], [0, 75], [115, -20]), ([-10, 110], [0, 75], [135, -20]), ([15, 110], [0, 75], [135, -20])],
        [([80, 110], [0, 75], [135, -20]), ([57, 110], [0, 75], [135, -20]), ([20, 110], [0, 75], [145, -20]), ([25, 110], [0, 75], [115, -20]), ([5, 110], [0, 75], [115, -20])]
    ]

    color_vector = [
        [Color(0.6901960784313725, 0.7529411764705882, 0.7372549019607844, 1), Color(0.4666666666666667, 0.2, 0.26666666666666666, 1), Color(0.8313725490196079, 0.30196078431372547, 0.3607843137254902, 1), Color(0.4196078431372549, 0.058823529411764705, 0.10196078431372549, 1), Color(0.5254901960784314, 0.3803921568627451, 0.3607843137254902, 1)], 
        [Color(0.8588235294117647, 0.6784313725490196, 0.41568627450980394, 1), Color(0.6862745098039216, 0.8784313725490196, 0.807843137254902, 1), Color(0.3843137254901961, 0.5137254901960784, 0.5843137254901961, 1), Color(0.5019607843137255, 0, 0.5019607843137255, 1), Color(0.9764705882352941, 0.43529411764705883, 0.36470588235294116, 1)], 
        [Color(0.13725490196078433, 0.807843137254902, 0.4196078431372549, 1), Color(0.15294117647058825, 0.6039215686274509, 0.9450980392156862, 1), Color(1, 0.8392156862745098, 0.2235294117647059, 1), Color(1, 0, 0, 1), Color(0.16470588235294117, 0.047058823529411764, 0.3058823529411765, 1)]
    ]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.simulation_thread = None


        global appInstance
        appInstance = self


        Window.clearcolor = (0.8509803921568627, 0.8509803921568627, 0.8509803921568627, 1)
        Window.maximize()
        
        self.add_widget(HorizontalBar())
        self.add_widget(VerticalBar())

        # Allows any name to fit by constraint of 1500 cm (accounts for long names)
        header_dashboard = GridLayout(cols=1, height=100, pos=(130, 380))
        header_dashboard.add_widget(Label(text="Howdy, {}!".format(userdata["name"]), text_size=(1500, None), font_name="Alatsi", font_size=100))
        self.add_widget(header_dashboard)

        for i in range(3):
            for j in range(5):
                currentrbxobj = RoundedBox(text_content=self.text_content_vector[i][j], editoffset=[i, j], color=self.color_vector[i][j], font_size=self.text_size_vector[i][j], font_offset=self.text_offset_vector[i][j], corner_radius=19, size=(272, 209), pos=(340 + (300 * j), 600 - (230 * i)))
                self.add_widget(currentrbxobj)
                roundbox.append(currentrbxobj)

        # Disable write permission for 15th widget
        self.remove_widget(roundbox[-1])
        roundbox.pop()
        roundbox.append(RoundedBox(text_content=self.text_content_vector[i][j], color=self.color_vector[i][j], font_size=self.text_size_vector[i][j], font_offset=self.text_offset_vector[i][j], corner_radius=19, size=(272, 209), pos=(340 + (300 * j), 600 - (230 * i))))
        self.add_widget(roundbox[-1])

        # Add buttons controlling simulation program
        self.runbtn = PillButton(icon=os.getcwd() + "\\Assets\\play.png", size_hint=(0.07, 0.07), size=(200, 50), pos=(1500, 30))
        self.stopbtn = PillButton(icon=os.getcwd() + "\\Assets\\stop.png", size_hint=(0.07, 0.07), size=(200, 50), pos=(1650, 30))

        self.runbtn.bind(on_press=self.start_simulation)
        self.stopbtn.bind(on_press=self.stop_simulation)

        self.add_widget(self.runbtn)
        self.add_widget(self.stopbtn)

    """
    *********************************
    start_simulation, on_simulation_finished, stop_simulation, and update_heartSimulationBox are all responsible for dynamically updating the 15th widget in the dashboard
    *********************************
    """

    def start_simulation(self, instance):
        if not self.simulation_thread:
            self.simulation_thread = SimulationThread()
            self.simulation_thread.start()

            while not self.simulation_thread.finished:
                continue
            else: 
                self.on_simulation_finished()
    
    def on_simulation_finished(self):
        self.update_heartSimulationBox(self.simulation_thread.result)

    def stop_simulation(self, instance):
        if self.simulation_thread and self.simulation_thread.running:
            self.simulation_thread.stop()

    def update_heartSimulationBox(self, result=None, customRoundBoxIdx=None, customRoundBoxText=None):
        global roundbox
        
        if result != None:
            self.remove_widget(roundbox[-1])
            roundbox[-1] = RoundedBox(text_content=(result, "", "Angiographic Disease"), color=self.color_vector[2][-1], font_size=self.text_size_vector[2][-1], font_offset=self.text_offset_vector[2][-1], corner_radius=19, size=(272, 209), pos=(340 + (300 * 4), 600 - (230 * 2)))
            self.add_widget(roundbox[-1])
        else:
            self.remove_widget(roundbox[customRoundBoxIdx])
            pairings = {0:(0, 0), 1:(0, 1), 2:(0, 2), 3:(0, 3), 4:(0, 4), 5:(1, 0), 6:(1, 1), 7:(1, 2), 8:(1, 3), 9:(1, 4), 10:(2, 0), 11:(2, 1), 12:(2, 2), 13:(2, 3)}
            roundbox[customRoundBoxIdx] = RoundedBox(text_content=(str(customRoundBoxText), self.text_content_vector[pairings[customRoundBoxIdx][0]][pairings[customRoundBoxIdx][1]][1], self.text_content_vector[pairings[customRoundBoxIdx][0]][pairings[customRoundBoxIdx][1]][2]), editoffset=[pairings[customRoundBoxIdx][0], pairings[customRoundBoxIdx][1]], color=self.color_vector[pairings[customRoundBoxIdx][0]][pairings[customRoundBoxIdx][1]], font_size=self.text_size_vector[pairings[customRoundBoxIdx][0]][pairings[customRoundBoxIdx][1]], font_offset=self.text_offset_vector[pairings[customRoundBoxIdx][0]][pairings[customRoundBoxIdx][1]], corner_radius=19, size=(272, 209), pos=(340 + (300 * pairings[customRoundBoxIdx][1]), 600 - (230 * pairings[customRoundBoxIdx][0])))
            self.add_widget(roundbox[customRoundBoxIdx])
        
    """
    Edit Mode -- allows you to edit the 14 widgets present in your dashboard!
    """
    def edit_value_popup(self, title, attrib):
        attributes_indices = {'trestbps': 0, 'chol': 1, 'thalch': 2, 'oldpeak': 3, 'slope': 4, 'fbs': 5, 'restecg': 6, 'exang': 7, 'ca': 8, 'crp': 9, 'cp': 10, 'thal': 11, 'ef': 12, 'bnp': 13, 'num': 14}
        def update_value_and_close_popup(instance, index, value):
            cat_mapping = {
                'sex': {'Male': 0, 'Female': 1},
                'cp': {'Asymptomatic': 0, 'Atypical angina': 1, 'Non-anginal': 2, 'Typical angina': 3},
                'restecg': {'LV Hypertrophy': 0, 'Normal': 1, 'ST-T abnormality': 2},
                'slope': {'Downsloping': 0, 'Flat': 1, 'Upsloping': 2},
                'thal': {'Fixed Defect': 0, 'Normal': 1, 'Reversible Defect': 2}
            }
            userdata[attrib] = cat_mapping[attrib][value] if (attrib in cat_mapping.keys()) else (float(value) if (attrib in ["oldpeak", "fbs", "restecg", "ef", "bnp", "crp"]) else int(value))
            

            with open(os.getcwd() + 'userdata.json', 'w') as json_file:
                json.dump(userdata, json_file, indent=4)
            popup.dismiss()

            self.update_heartSimulationBox(customRoundBoxIdx=index, customRoundBoxText=(value if attrib != "oldpeak" else "{:+}".format(userdata["oldpeak"]) if userdata["oldpeak"] >= 0 else "{}".format(userdata["oldpeak"])))
        
        if (attrib in ['sex', 'cp', 'restecg', 'slope', 'thal']): 
            popup = Popup(title='Edit {}'.format(title), size_hint=(.4, .2), size=(250, 50))
            dropdown = DropDown()

            match attrib:
                case 'sex':
                    options = ['Male', 'Female']
                case 'cp':
                    options = ['Asymptomatic', 'Atypical angina', 'Non-anginal', 'Typical angina']
                case 'restecg':
                    options = ['LV Hypertrophy', 'Normal', 'ST-T abnormality']
                case 'slope':
                    options = ['Downsloping', 'Flat', 'Upsloping']
                case 'thal':
                    options = ['Fixed Defect', 'Normal', 'Reversible Defect']

            for option in options:
                btn = Button(text=option, size_hint_y=None, height=35, size=(200, 40))
                btn.bind(on_release=lambda btn: update_value_and_close_popup(btn, attributes_indices[attrib], btn.text))
                dropdown.add_widget(btn)

            button = Button(text='Select', size_hint=(None, None), size=(100, 40), pos=(590, 700))
            button.bind(on_release=dropdown.open)
            popup.add_widget(button)
            
            popup.open()

        else:
            popup = Popup(title='Edit {}'.format(title), size_hint=(.4, .2), size=(250, 50))
            popup.content = FloatLayout()
            input_field = TextInput(text=str(userdata[attrib]), multiline=False, size_hint=(None, None), size=(popup.size[0] / 5, 30), pos=(590, 520))
            popup.content.add_widget(input_field)
            save_button = Button(text='Save', size_hint=(None, None), size=(100, 40), pos=(590, 420))
            save_button.bind(on_press=lambda instance: update_value_and_close_popup(instance, attributes_indices[attrib], input_field.text))
            popup.content.add_widget(save_button)
        
            popup.open()  