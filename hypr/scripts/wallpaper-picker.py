#!/usr/bin/env python3
"""Bottom wallpaper carousel: smooth horizontal scrolling, keyboard + mouse.
Keys: Left/Right (h/l) move, Home/End jump, Enter apply, Esc close.  Mouse: wheel scrolls, click applies."""
import os, sys, subprocess, math
import gi
gi.require_version("Gtk", "4.0"); gi.require_version("Gdk", "4.0"); gi.require_version("Gtk4LayerShell", "1.0")
from gi.repository import Gtk, Gdk, GLib, Gtk4LayerShell as LS

HOME = os.path.expanduser("~")
WALLDIR = os.path.join(HOME, "Pictures", "Wallpapers")
THUMBS = os.path.join(HOME, ".cache", "wallthumbs")
SETTER = os.path.join(HOME, ".config", "hypr", "scripts", "set-wallpaper.sh")
EXT = (".png", ".jpg", ".jpeg", ".webp")
CARD_W, CARD_H, GAP = 280, 158, 22

def palette():
    import re
    d = {"primary": "#a0cdfa", "surface": "#0e1216", "on-surface": "#e0e2e8"}
    try:
        txt = open(os.path.join(HOME, ".config", "rofi", "colors.rasi")).read()
        for k in d:
            m = re.search(r"^\s*%s:\s*(#[0-9a-fA-F]{6})" % re.escape(k), txt, re.M)
            if m: d[k] = m.group(1)
    except OSError:
        pass
    return d

def rgba(hexc, a):
    h = hexc.lstrip("#"); return "rgba(%d,%d,%d,%s)" % (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)

P = palette()
CSS = ("""
window.picker { background: transparent; }
.strip { background: SURF80; border: 1px solid rgba(255,255,255,0.10); border-radius: 30px; }
scrolledwindow { background: transparent; }
.card { background: transparent; border-radius: 22px; padding: 12px; border: 2px solid transparent; }
.card.sel { background: PRIM20; border-color: #a8e063; }
.card picture { border-radius: 14px; }
.card label { color: ONSURF; font-size: 12px; margin-top: 8px; opacity: 0.8; }
.card.sel label { opacity: 1; font-weight: 700; }
.hint { color: ONSURF45; font-size: 11px; }
""").replace("SURF80", rgba(P["surface"], 0.82)).replace("PRIM20", rgba(P["primary"], 0.24)).replace("ONSURF45", rgba(P["on-surface"], 0.45)).replace("ONSURF", P["on-surface"]).encode()


class Picker(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="org.isg.wallpaperpicker")
        self.files, self.cards, self.sel = [], [], 0
        self.anim = None

    def do_activate(self):
        self.files = sorted(f for f in os.listdir(WALLDIR) if f.lower().endswith(EXT))
        if not self.files:
            subprocess.run(["notify-send", "Wallpapers", "No images in ~/Pictures/Wallpapers"]); return
        cur = ""
        try: cur = os.path.basename(open(os.path.join(HOME, ".cache", "last-wallpaper")).read().strip())
        except OSError: pass
        self.sel = self.files.index(cur) if cur in self.files else 0

        prov = Gtk.CssProvider(); prov.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        win = self.win = Gtk.ApplicationWindow(application=self)
        win.add_css_class("picker")
        LS.init_for_window(win)
        LS.set_namespace(win, "wallpaper-picker")
        LS.set_layer(win, LS.Layer.OVERLAY)
        LS.set_keyboard_mode(win, LS.KeyboardMode.EXCLUSIVE)
        for edge, m in ((LS.Edge.BOTTOM, 12), (LS.Edge.LEFT, 12), (LS.Edge.RIGHT, 12)):
            LS.set_anchor(win, edge, True); LS.set_margin(win, edge, m)

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL); outer.add_css_class("strip")
        self.scroller = Gtk.ScrolledWindow()
        self.scroller.set_policy(Gtk.PolicyType.EXTERNAL, Gtk.PolicyType.NEVER)   # no visible scrollbar
        self.scroller.set_size_request(-1, CARD_H + 90)
        self.scroller.set_kinetic_scrolling(True)
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=GAP)
        row.set_margin_top(16); row.set_margin_bottom(8)
        self.row = row
        for i, name in enumerate(self.files):
            thumb = os.path.join(THUMBS, os.path.splitext(name)[0] + ".png")
            pic = Gtk.Picture.new_for_filename(thumb if os.path.exists(thumb) else os.path.join(WALLDIR, name))
            pic.set_content_fit(Gtk.ContentFit.COVER); pic.set_size_request(CARD_W, CARD_H)
            pic.set_can_shrink(True); pic.set_overflow(Gtk.Overflow.HIDDEN)
            lab = Gtk.Label(label=os.path.splitext(name)[0]); lab.set_ellipsize(3); lab.set_max_width_chars(28)
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL); card.add_css_class("card")
            card.append(pic); card.append(lab)
            g = Gtk.GestureClick(); g.connect("released", lambda *_a, i=i: self.apply(i)); card.add_controller(g)
            row.append(card); self.cards.append(card)
        self.scroller.set_child(row)
        outer.append(self.scroller)
        hint = Gtk.Label(label="←  →  browse     Enter  apply     Esc  close"); hint.add_css_class("hint"); hint.set_margin_bottom(10)
        outer.append(hint)
        win.set_child(outer)

        keys = Gtk.EventControllerKey(); keys.connect("key-pressed", self.on_key); win.add_controller(keys)
        wheel = Gtk.EventControllerScroll.new(Gtk.EventControllerScrollFlags.BOTH_AXES)
        wheel.connect("scroll", self.on_wheel); self.scroller.add_controller(wheel)
        win.present()
        GLib.timeout_add(60, self.select, self.sel, False)   # center current wallpaper once laid out

    # ---- selection + smooth centering ----
    def select(self, i, animate=True):
        self.sel = max(0, min(len(self.files) - 1, i))
        for n, c in enumerate(self.cards):
            (c.add_css_class if n == self.sel else c.remove_css_class)("sel")
        adj = self.scroller.get_hadjustment()
        step = CARD_W + 24 + GAP
        target = self.sel * step + (CARD_W + 24) / 2 + 18 - adj.get_page_size() / 2
        target = max(0, min(target, adj.get_upper() - adj.get_page_size()))
        self.glide(adj, target) if animate else adj.set_value(target)
        return False

    def glide(self, adj, target):
        if self.anim: GLib.source_remove(self.anim)
        start, t0, dur = adj.get_value(), GLib.get_monotonic_time(), 260_000
        def tick():
            t = min(1.0, (GLib.get_monotonic_time() - t0) / dur)
            e = 1 - (1 - t) ** 3                        # ease-out cubic
            adj.set_value(start + (target - start) * e)
            if t >= 1.0: self.anim = None; return False
            return True
        self.anim = GLib.timeout_add(8, tick)

    def on_wheel(self, _c, dx, dy):
        d = dx if abs(dx) > abs(dy) else dy
        if abs(d) < 0.01: return True
        self.select(self.sel + (1 if d > 0 else -1)); return True

    def on_key(self, _c, keyval, _code, _state):
        k = Gdk.keyval_name(keyval)
        if k in ("Right", "l", "Down"): self.select(self.sel + 1)
        elif k in ("Left", "h", "Up"): self.select(self.sel - 1)
        elif k == "Home": self.select(0)
        elif k == "End": self.select(len(self.files) - 1)
        elif k in ("Return", "KP_Enter"): self.apply(self.sel)
        elif k == "Escape": self.quit()
        else: return False
        return True

    def apply(self, i):
        path = os.path.join(WALLDIR, self.files[i])
        subprocess.Popen([SETTER, path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
        self.quit()


if __name__ == "__main__":
    sys.exit(Picker().run([]))
