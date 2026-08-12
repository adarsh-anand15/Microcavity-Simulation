"""Microcavity Simulation - Kivy Android port.

Reflectivity, field-profile animation, and dispersion plots for a DBR and for a
microcavity (two DBRs around a cavity layer), using the transfer-matrix physics
in physics.py (ported from the original MATLAB App Designer app).

Plotting uses a small custom pure-Kivy widget instead of matplotlib, since it
keeps the Android build lightweight and avoids matplotlib's heavier
python-for-android recipe.
"""
import numpy as np

from kivy.app import App
from kivy.clock import Clock
from kivy.graphics import Color, Line
from kivy.metrics import dp
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.gridlayout import GridLayout
from kivy.uix.label import Label
from kivy.uix.scrollview import ScrollView
from kivy.uix.tabbedpanel import TabbedPanel, TabbedPanelItem
from kivy.uix.textinput import TextInput
from kivy.uix.togglebutton import ToggleButton
from kivy.uix.widget import Widget

import physics

S_COLOR = (0.30, 0.55, 1.00, 1)
P_COLOR = (1.00, 0.35, 0.35, 1)
R_COLOR = (0.30, 0.85, 0.35, 1)


class PlotWidget(Widget):
    """Draws one or more (x, y, rgba) curves scaled to fill the widget."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.curves = []
        self.bind(pos=self.redraw, size=self.redraw)

    def set_curves(self, curves):
        self.curves = curves
        self.redraw()

    def redraw(self, *args):
        self.canvas.clear()
        if not self.curves or self.width < 2 or self.height < 2:
            return
        all_x = np.concatenate([c[0] for c in self.curves])
        all_y = np.concatenate([c[1] for c in self.curves])
        xmin, xmax = float(np.min(all_x)), float(np.max(all_x))
        ymin, ymax = float(np.min(all_y)), float(np.max(all_y))
        if xmax == xmin:
            xmax = xmin + 1
        if ymax == ymin:
            ymin, ymax = ymin - 1, ymax + 1
        yr = ymax - ymin
        ymin -= yr * 0.05
        ymax += yr * 0.05

        x0, y0 = self.pos
        w, h = self.size
        with self.canvas:
            Color(0.55, 0.55, 0.55, 1)
            Line(rectangle=(x0, y0, w, h), width=1)
            if ymin < 0 < ymax:
                zy = y0 + (0 - ymin) / (ymax - ymin) * h
                Color(0.4, 0.4, 0.4, 1)
                Line(points=[x0, zy, x0 + w, zy], width=1)
            for x, y, color in self.curves:
                px = x0 + (np.asarray(x) - xmin) / (xmax - xmin) * w
                py = y0 + (np.asarray(y) - ymin) / (ymax - ymin) * h
                pts = np.empty(len(x) * 2)
                pts[0::2] = px
                pts[1::2] = py
                Color(*color)
                Line(points=pts.tolist(), width=1.3)


def labeled_field(label_text, default):
    row = BoxLayout(size_hint_y=None, height=dp(40), spacing=dp(4))
    lbl = Label(text=label_text, size_hint_x=0.58, halign='left', valign='middle',
                font_size='12sp', shorten=True, shorten_from='right')
    lbl.bind(size=lbl.setter('text_size'))
    row.add_widget(lbl)
    ti = TextInput(text=str(default), multiline=False, size_hint_x=0.42,
                    input_filter='float', write_tab=False, font_size='13sp')
    row.add_widget(ti)
    return row, ti


class ParamForm(GridLayout):
    def __init__(self, fields, **kwargs):
        super().__init__(cols=1, size_hint_y=None, spacing=dp(3), padding=dp(6), **kwargs)
        self.bind(minimum_height=self.setter('height'))
        self.inputs = {}
        for key, label_text, default in fields:
            row, ti = labeled_field(label_text, default)
            self.add_widget(row)
            self.inputs[key] = ti

    def values(self):
        out = {}
        for key, ti in self.inputs.items():
            try:
                out[key] = float(ti.text)
            except ValueError:
                out[key] = 0.0
        return out


DBR_FIELDS = [
    ('thetai', 'Angle of incidence (deg)', physics.DBR_DEFAULTS['thetai']),
    ('thetaEi', 'E-field / plane angle (deg)', physics.DBR_DEFAULTS['thetaEi']),
    ('Ei', 'Initial field amplitude', physics.DBR_DEFAULTS['Ei']),
    ('ni', 'n (initial medium)', physics.DBR_DEFAULTS['ni']),
    ('nf', 'n (final medium)', physics.DBR_DEFAULTS['nf']),
    ('LambdaC', 'Central wavelength (nm)', physics.DBR_DEFAULTS['LambdaC']),
    ('LambdaD', 'Design wavelength (nm)', physics.DBR_DEFAULTS['LambdaD']),
    ('n1', 'n1 (layer index)', physics.DBR_DEFAULTS['n1']),
    ('n2', 'n2 (layer index)', physics.DBR_DEFAULTS['n2']),
    ('N', 'N (number of layers)', physics.DBR_DEFAULTS['N']),
]

MICROCAVITY_FIELDS = [
    ('thetai', 'Angle of incidence (deg)', physics.MICROCAVITY_DEFAULTS['thetai']),
    ('thetaEi', 'E-field / plane angle (deg)', physics.MICROCAVITY_DEFAULTS['thetaEi']),
    ('Ei', 'Initial field amplitude', physics.MICROCAVITY_DEFAULTS['Ei']),
    ('ni', 'n (initial medium)', physics.MICROCAVITY_DEFAULTS['ni']),
    ('nf', 'n (final medium)', physics.MICROCAVITY_DEFAULTS['nf']),
    ('LambdaC', 'Central wavelength (nm)', physics.MICROCAVITY_DEFAULTS['LambdaC']),
    ('LambdaD1', 'DBR1 design wavelength (nm)', physics.MICROCAVITY_DEFAULTS['LambdaD1']),
    ('D1_n1', 'DBR1 n1', physics.MICROCAVITY_DEFAULTS['D1_n1']),
    ('D1_n2', 'DBR1 n2', physics.MICROCAVITY_DEFAULTS['D1_n2']),
    ('D1_N', 'DBR1 N layers', physics.MICROCAVITY_DEFAULTS['D1_N']),
    ('LambdaD2', 'DBR2 design wavelength (nm)', physics.MICROCAVITY_DEFAULTS['LambdaD2']),
    ('D2_n1', 'DBR2 n1', physics.MICROCAVITY_DEFAULTS['D2_n1']),
    ('D2_n2', 'DBR2 n2', physics.MICROCAVITY_DEFAULTS['D2_n2']),
    ('D2_N', 'DBR2 N layers', physics.MICROCAVITY_DEFAULTS['D2_N']),
    ('LambdaDc', 'Cavity design wavelength (nm)', physics.MICROCAVITY_DEFAULTS['LambdaDc']),
    ('nc', 'Cavity n', physics.MICROCAVITY_DEFAULTS['nc']),
]


class SimTab(BoxLayout):
    """Shared layout: left scrollable param form, right plot + controls."""

    def __init__(self, fields, **kwargs):
        super().__init__(orientation='horizontal', spacing=dp(6), padding=dp(6), **kwargs)
        self.form = ParamForm(fields)
        scroller = ScrollView(size_hint=(None, 1), width=dp(320))
        scroller.add_widget(self.form)
        self.add_widget(scroller)

        right = BoxLayout(orientation='vertical', spacing=dp(4))
        self.button_row = BoxLayout(size_hint_y=None, height=dp(48), spacing=dp(4))
        right.add_widget(self.button_row)
        self.plot = PlotWidget()
        right.add_widget(self.plot)
        self.status = Label(text='', size_hint_y=None, height=dp(28), font_size='12sp',
                             halign='left', valign='middle', shorten=True)
        self.status.bind(size=self.status.setter('text_size'))
        right.add_widget(self.status)
        self.add_widget(right)

        self.field_event = None

    def stop_animation(self):
        if self.field_event is not None:
            self.field_event.cancel()
            self.field_event = None

    def on_leave(self):
        self.stop_animation()


class DBRTab(SimTab):
    def __init__(self, **kwargs):
        super().__init__(DBR_FIELDS, **kwargs)

        refl_btn = Button(text='Reflectivity')
        refl_btn.bind(on_release=self.plot_reflectivity)
        self.button_row.add_widget(refl_btn)

        self.anim_btn = ToggleButton(text='Field Profile')
        self.anim_btn.bind(on_press=self.toggle_field_profile)
        self.button_row.add_widget(self.anim_btn)

    def plot_reflectivity(self, *_args):
        self.stop_animation()
        self.anim_btn.state = 'normal'
        p = self.form.values()
        p['N'] = int(p['N'])
        Lambda, Rs, Rp, R = physics.dbr_reflectivity(p)
        self.plot.set_curves([(Lambda, Rs, S_COLOR), (Lambda, Rp, P_COLOR), (Lambda, R, R_COLOR)])
        self.status.text = 'Reflectivity vs Wavelength  (blue=s  red=p  green=given pol.)'

    def toggle_field_profile(self, instance):
        if instance.state == 'down':
            p = self.form.values()
            p['N'] = int(p['N'])
            p['thetai'] = 0.0
            self.stack, _, _ = physics.ds_dbr(p)
            self.lambda_c = p['LambdaC']
            self.Ei = p['Ei']
            self.t = 0.0
            self.dt = 0.1 * self.lambda_c / (4 * physics.LIGHT_SPEED)
            self.field_event = Clock.schedule_interval(self._field_tick, 1 / 15)
        else:
            self.stop_animation()

    def _field_tick(self, _dt):
        x, y = physics.stack_field_profile(self.stack, self.lambda_c, self.Ei, self.t)
        self.plot.set_curves([(x, y, S_COLOR)])
        frac = self.t * 4 * physics.LIGHT_SPEED / self.lambda_c
        self.status.text = f'Electric Field Profile   t = {frac:.2f} * LambdaC/(4c)'
        self.t += self.dt


class MicrocavityTab(SimTab):
    def __init__(self, **kwargs):
        super().__init__(MICROCAVITY_FIELDS, **kwargs)

        refl_btn = Button(text='Reflectivity')
        refl_btn.bind(on_release=self.plot_reflectivity)
        self.button_row.add_widget(refl_btn)

        self.anim_btn = ToggleButton(text='Field Profile')
        self.anim_btn.bind(on_press=self.toggle_field_profile)
        self.button_row.add_widget(self.anim_btn)

        disp_btn = Button(text='E vs k||')
        disp_btn.bind(on_release=self.plot_dispersion)
        self.button_row.add_widget(disp_btn)

        res_btn = Button(text='λ vs θ')
        res_btn.bind(on_release=self.plot_resonance_vs_angle)
        self.button_row.add_widget(res_btn)

    def plot_reflectivity(self, *_args):
        self.stop_animation()
        self.anim_btn.state = 'normal'
        p = self.form.values()
        p['D1_N'] = int(p['D1_N'])
        p['D2_N'] = int(p['D2_N'])
        Lambda, Rs, Rp, R = physics.microcavity_reflectivity(p)
        self.plot.set_curves([(Lambda, Rs, S_COLOR), (Lambda, Rp, P_COLOR), (Lambda, R, R_COLOR)])
        self.status.text = 'Reflectivity vs Wavelength  (blue=s  red=p  green=given pol.)'

    def toggle_field_profile(self, instance):
        if instance.state == 'down':
            p = self.form.values()
            p['D1_N'] = int(p['D1_N'])
            p['D2_N'] = int(p['D2_N'])
            p['thetai'] = 0.0
            self.stack, extras = physics.ds_microcavity(p)
            self.lambda_c = p['LambdaC']
            self.Ei = p['Ei']
            self.nc = p['nc']
            self.t = 0.0
            self.dt = 0.1 * self.lambda_c / (4 * physics.LIGHT_SPEED * self.nc)
            self.field_event = Clock.schedule_interval(self._field_tick, 1 / 15)
        else:
            self.stop_animation()

    def _field_tick(self, _dt):
        x, y = physics.stack_field_profile(self.stack, self.lambda_c, self.Ei, self.t)
        self.plot.set_curves([(x, y, S_COLOR)])
        frac = self.t * 4 * physics.LIGHT_SPEED * self.nc / self.lambda_c
        self.status.text = f'Electric Field Profile   t = {frac:.2f} * LambdaC/(4c)'
        self.t += self.dt

    def _run_expensive(self, label_text, compute_fn):
        self.stop_animation()
        self.anim_btn.state = 'normal'
        self.status.text = label_text + ' — computing…'
        Clock.schedule_once(lambda _dt: compute_fn(), 0.05)

    def plot_dispersion(self, *_args):
        p = self.form.values()
        p['D1_N'] = int(p['D1_N'])
        p['D2_N'] = int(p['D2_N'])

        def compute():
            d = physics.dispersion_vs_k_parallel(p)
            self.plot.set_curves([
                (d['kparallel_s'], d['Us'], S_COLOR),
                (d['kparallel_p'], d['Up'], P_COLOR),
            ])
            self.status.text = 'Energy (J) vs k_parallel (1/µm)  (blue=s  red=p)'

        self._run_expensive('Energy vs k_parallel', compute)

    def plot_resonance_vs_angle(self, *_args):
        p = self.form.values()
        p['D1_N'] = int(p['D1_N'])
        p['D2_N'] = int(p['D2_N'])

        def compute():
            theta_deg, LambdaCRs, LambdaCRp = physics.resonance_vs_angle(p)
            self.plot.set_curves([
                (theta_deg, LambdaCRs, S_COLOR),
                (theta_deg, LambdaCRp, P_COLOR),
            ])
            self.status.text = 'Resonance Wavelength (nm) vs Angle of Incidence (deg)  (blue=s  red=p)'

        self._run_expensive('Resonance wavelength vs angle', compute)


class MicrocavitySimApp(App):
    title = 'Microcavity Simulation'

    def build(self):
        panel = TabbedPanel(do_default_tab=False)

        dbr_item = TabbedPanelItem(text='DBR')
        dbr_tab = DBRTab()
        dbr_item.add_widget(dbr_tab)
        panel.add_widget(dbr_item)

        mc_item = TabbedPanelItem(text='Microcavity')
        mc_tab = MicrocavityTab()
        mc_item.add_widget(mc_tab)
        panel.add_widget(mc_item)

        self._tabs = [dbr_tab, mc_tab]

        def _stop_others(*_args):
            for t in self._tabs:
                t.stop_animation()

        panel.bind(current_tab=_stop_others)
        return panel

    def on_pause(self):
        for t in self._tabs:
            t.stop_animation()
        return True

    def on_stop(self):
        for t in self._tabs:
            t.stop_animation()


if __name__ == '__main__':
    MicrocavitySimApp().run()
