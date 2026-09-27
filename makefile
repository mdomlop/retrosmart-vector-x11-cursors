# # ===========================================================================
# retrosmart-vector-x11-cursors — Makefile
# ===========================================================================
NAME    := retrosmart
PKGNAME := xcursor-$(NAME)-vector

VERSION     := 1.0b
URL         := https://github.com/mdomlop/retrosmart-vector-x11-cursors
DESCRIPTION := A retrosmart look collection of cursors for X (vectorized).
LICENSE     := GPL3
MAIL        := zqbzybc@tznvy.pbz
YEAR        := 2026

DEBARCH  := all
DEBPKG   := $(PKGNAME)_$(VERSION)_$(DEBARCH).deb
DEB_DIR  := debian_pkg

ARCHPKGEXT := '.pkg.tar.zst'
ARCHPKG := $(PKGNAME)-$(VERSION)-1-any$(ARCHPKGEXT)
ARCH_DIR := arch_pkg

# No dejes que las reglas y variables implícitas de Make interfieran con
# las reglas de patrón propias de este proyecto.
MAKEFLAGS += -r -R

.DEFAULT_GOAL := all
.DELETE_ON_ERROR:

THREADS := $(shell echo "$(MAKEFLAGS)" | grep -oP '(?<=-j)\d+' || echo 1)
SIZES := 32 36 40 48 56 64 72 80 88 96

# ---------------------------------------------------------------------------
# Descubrimiento de fuentes
# ---------------------------------------------------------------------------
SRCSVGTHEMES := $(wildcard src/$(NAME)-vector-xcursor-*.theme)
SRCSVGS      := $(wildcard src/vector.base/*.svg)

SVGTHEMES := $(notdir $(basename $(SRCSVGTHEMES)))

SVGINDICES := $(SVGTHEMES:=/index.theme) $(SVGTHEMES:=/cursor.theme)
INDICES    := $(SVGINDICES)

SVGS := $(foreach dir,$(SVGTHEMES),$(addprefix svg/$(dir)/,$(notdir $(SRCSVGS))))

CURSORSNAMES := alias all-scroll bottom_left_corner bottom_right_corner bottom_side cell center_ptr closedhand color-picker col-resize context-menu copy crosshair default dnd-move dnd-no-drop down-arrow draft fleur help left-arrow left_side no-drop not-allowed openhand pencil pirate pointer progress right-arrow right_ptr right_side row-resize size_bdiag size_fdiag size_hor size_ver text top_left_corner top_right_corner top_side up-arrow vertical-text wait wayland-cursor x-cursor zoom-in zoom-out

CURSORCONF := $(addsuffix .in,$(CURSORSNAMES))
CURSORCONF := $(addprefix svgconf/,$(CURSORCONF))

# Alias de cursor: cada entrada es "enlace:origen". El enlace simbólico
# "%/<enlace>" apuntará a "%/<origen>" (que puede ser, a su vez, otro
# alias: las cadenas de varios niveles funcionan sin cambios).
LINKPAIRS := \
	00000000000000020006000e7e9ffc3f:progress \
	00008160000006810000408080010102:size_ver \
	03b6e0fcb3499374a867c041f52298f0:circle \
	08e8e1c95fe2fc01f976f1e063a24ccd:progress \
	1081e37283d90000800003c07f3ef6bf:copy \
	3085a0e285430894940527032f8b26df:alias \
	3ecb610c1bf2410f44200f48c40d3599:progress \
	4498f0e0c1937ffe01fd06f973665830:dnd-move \
	5c6cd98b3f3ebcb1f9c7f1c204630408:help \
	6407b0e94181790501fd1e167b474872:copy \
	640fb0e74195791501fd1ed57b41487f:alias \
	9081237383d90e509aa00f00170e968f:dnd-move \
	9d800788f1b08800ae810202380a0822:pointer \
	a2a266d0498c3104214a47bd64ab0fc8:alias \
	arrow:left_ptr \
	b66166c04f8c3109214a4fbd64a50fc8:copy \
	circle:not-allowed \
	cross:crosshair \
	crossed_circle:not-allowed \
	d9ce0ab605698f320427677b458ad60b:help \
	dnd-copy:copy \
	dnd-none:dnd-move \
	e29285e634086352946a0e7090d73106:pointer \
	e-resize:size_hor \
	fcf21c00b30f7e3f83fe0dfd12e71cff:dnd-move \
	forbidden:no-drop \
	half-busy:progress \
	hand1:pointer \
	hand2:pointer \
	h_double_arrow:size_hor \
	ibeam:text \
	left_ptr:default \
	left_ptr_help:help \
	left_ptr_watch:progress \
	link:alias \
	move:closedhand \
	ne-resize:size_bdiag \
	n-resize:size_ver \
	nw-resize:size_fdiag \
	plus:cell \
	pointing_hand:pointer \
	question_arrow:help \
	sb_h_double_arrow:size_hor \
	sb_v_double_arrow:size_ver \
	se-resize:size_fdiag \
	size_all:fleur \
	size-bdiag:default \
	size-fdiag:default \
	size-hor:default \
	size-ver:default \
	split_h:col-resize \
	split_v:row-resize \
	s-resize:size_ver \
	sw-resize:size_bdiag \
	top_left_arrow:default \
	v_double_arrow:size_ver \
	watch:wait \
	whats_this:help \
	w-resize:size_hor \
	xterm:text \
	ew-resize:size_hor \
	grab:openhand \
	grabbing:closedhand \
	nesw-resize:size_bdiag \
	ns-resize:size_ver \
	nwse-resize:size_fdiag \
	tcross:crosshair

LINKSNAMES := $(foreach p,$(LINKPAIRS),$(word 1,$(subst :, ,$(p))))


VARIANTS_NORMAL := \
	retrosmart-vector-xcursor-white \
	retrosmart-vector-xcursor-white-color \
	retrosmart-vector-xcursor-black \
	retrosmart-vector-xcursor-black-color

VARIANTS_SHADOW := \
	retrosmart-vector-xcursor-white-shadow \
	retrosmart-vector-xcursor-white-color-shadow \
	retrosmart-vector-xcursor-black-shadow \
	retrosmart-vector-xcursor-black-color-shadow

VARIANTS_ALL := $(VARIANTS_NORMAL) $(VARIANTS_SHADOW)

RSVGCONVERT := rsvg-convert
MAGICK      := magick
SVG2PNGARGSHADOW := \( +clone -background black -shadow 60x2+5+5 \) +swap -background none -layers merge +repage

# IMPORTANTE: SVGPNGS tiene que estar definida ANTES de generar las reglas
# de cursores (más abajo), porque estas la usan dentro de un $(eval ...) y
# las listas de prerrequisitos se expanden en el momento en que Make las
# parsea, no cuando se construye el target. Si se define después, el
# $(filter ...) se evalúa contra una variable todavía vacía y el resultado
# es "sin dependencia" para todas las variantes: exactamente el bug que
# rompía "make -j16".
SVGPNGS := $(foreach size,$(SIZES),$(addprefix $(size)-,$(notdir $(SRCSVGS))))
SVGPNGS := $(foreach dir,$(SVGTHEMES),$(addprefix svgpng/$(dir)/,$(SVGPNGS)))
SVGPNGS := $(SVGPNGS:.svg=.png)
PNGS    := $(SVGPNGS)

SVGCURSORS := $(foreach dir,$(SVGTHEMES),$(addprefix $(dir)/cursors/,$(CURSORSNAMES)))
CURSORS    := $(SVGCURSORS)

SVGLINKS := $(foreach dir,$(SVGTHEMES),$(addprefix $(dir)/cursors/,$(LINKSNAMES)))
LINKS    := $(SVGLINKS)

# ---------------------------------------------------------------------------
# Directorios de trabajo (svg/<variante>, svgpng/<variante>,
# <variante>/cursors). Se declaran como prerrequisitos "order-only" (con
# "|") en las reglas que los necesitan, en vez de hacer "mkdir -p" dentro
# de cada receta: así varios jobs en paralelo que escriben en el mismo
# directorio nunca compiten por crearlo al mismo tiempo.
# ---------------------------------------------------------------------------
ALL_DIRS := \
	$(addprefix svg/,$(VARIANTS_ALL)) \
	$(addprefix svgpng/,$(VARIANTS_ALL)) \
	$(addsuffix /cursors,$(VARIANTS_ALL))

$(ALL_DIRS):
	mkdir -p $@

# ---------------------------------------------------------------------------
# Enlaces simbólicos de alias de cursor (generados a partir de LINKPAIRS)
# ---------------------------------------------------------------------------
define LINK_RULE
%/$(word 1,$(subst :, ,$(1))): %/$(word 2,$(subst :, ,$(1)))
	cd $$(dir $$@); ln -sf $$(notdir $$^) $$(notdir $$@)
endef

$(foreach p,$(LINKPAIRS),$(eval $(call LINK_RULE,$(p))))

# ---------------------------------------------------------------------------
# index.theme / cursor.theme
# ---------------------------------------------------------------------------
%/index.theme: src/%.theme
	mkdir -p $(dir $@)
	cp $< $@
%/cursor.theme: src/%.theme
	mkdir -p $(dir $@)
	cp $< $@

# ---------------------------------------------------------------------------
# SVG por variante: sustituye los colores "cyan"/"coral" del SVG base por
# los colores finales de cada variante.
#
# Las variantes "*-color*" prefieren, si existe, el SVG específico de
# src/vector.base-color/; si no existe, caen automáticamente al SVG de
# src/vector.base/ (Make usa la primera regla de patrón cuyo prerrequisito
# exista). Las variantes normales solo usan src/vector.base/.
#
# Formato de cada entrada: variante:color_de_cyan:color_de_coral
# ---------------------------------------------------------------------------
SVGCOLORS_PLAIN := \
	retrosmart-vector-xcursor-white:white:black \
	retrosmart-vector-xcursor-white-shadow:white:black \
	retrosmart-vector-xcursor-black:black:white \
	retrosmart-vector-xcursor-black-shadow:black:white

SVGCOLORS_FALLBACK := \
	retrosmart-vector-xcursor-white-color:white:black \
	retrosmart-vector-xcursor-white-color-shadow:white:black \
	retrosmart-vector-xcursor-black-color:black:white \
	retrosmart-vector-xcursor-black-color-shadow:black:white

define SVG_RULE_PLAIN
svg/$(1)/%.svg: src/vector.base/%.svg | svg/$(1)
	sed -e 's/cyan/$(2)/g' -e 's/coral/$(3)/g' $$< > $$@
endef

define SVG_RULE_FALLBACK
svg/$(1)/%.svg: src/vector.base-color/%.svg | svg/$(1)
	sed -e 's/cyan/$(2)/g' -e 's/coral/$(3)/g' $$< > $$@
svg/$(1)/%.svg: src/vector.base/%.svg | svg/$(1)
	sed -e 's/cyan/$(2)/g' -e 's/coral/$(3)/g' $$< > $$@
endef

$(foreach e,$(SVGCOLORS_PLAIN),\
	$(eval $(call SVG_RULE_PLAIN,$(word 1,$(subst :, ,$(e))),$(word 2,$(subst :, ,$(e))),$(word 3,$(subst :, ,$(e))))))

$(foreach e,$(SVGCOLORS_FALLBACK),\
	$(eval $(call SVG_RULE_FALLBACK,$(word 1,$(subst :, ,$(e))),$(word 2,$(subst :, ,$(e))),$(word 3,$(subst :, ,$(e))))))

# ---------------------------------------------------------------------------
# SVG -> PNG (rsvg-convert), con sombra opcional (ImageMagick)
# ---------------------------------------------------------------------------
# $(1) = variante, $(2) = tamaño
define NORMAL_RULE
svgpng/$(1)/$(2)-%.png: svg/$(1)/%.svg | svgpng/$(1)
	$$(RSVGCONVERT) -w $(2) -h $(2) $$< -o $$@
endef

define SHADOW_RULE
svgpng/$(1)/$(2)-%.png: svg/$(1)/%.svg | svgpng/$(1)
	$$(RSVGCONVERT) -w $(2) -h $(2) $$< -o $$@
	$$(MAGICK) $$@ $$(SVG2PNGARGSHADOW) $$@
endef

$(foreach size,$(SIZES),\
	$(foreach v,$(VARIANTS_NORMAL),\
		$(eval $(call NORMAL_RULE,$(v),$(size)))))

$(foreach size,$(SIZES),\
	$(foreach v,$(VARIANTS_SHADOW),\
		$(eval $(call SHADOW_RULE,$(v),$(size)))))

# ---------------------------------------------------------------------------
# Cursores (xcursorgen). Cada cursor depende explícitamente de los PNG de
# SU variante (filtrados de $(SVGPNGS)); esa era la dependencia que faltaba
# y la causa real de que "make -j16" fallase de forma intermitente: sin
# ella, xcursorgen podía arrancar antes de que rsvg-convert terminase de
# generar los PNG que necesita.
# ---------------------------------------------------------------------------
define CURSOR_RULE
$(1)/cursors/%: svgconf/%.in $$(filter svgpng/$(1)/%,$$(SVGPNGS)) | $(1)/cursors
	xcursorgen -p svgpng/$(1) $$< $$@
endef

$(foreach v,$(VARIANTS_ALL),$(eval $(call CURSOR_RULE,$(v))))

# ---------------------------------------------------------------------------
# Targets de agrupación
# ---------------------------------------------------------------------------
all: svgtheme pkg_ocs pkg_deb pkg_arch

svgtheme: svghotspot svg svgpng svgcursor svgindex svglink

svghotspot: sethp.sh
	SIZES="$(SIZES)" sh ./sethp.sh svgconf

$(CURSORCONF): svghotspot

svg: $(SVGS)
svgpng: $(SVGPNGS)
svgcursor: $(SVGCURSORS)
svgindex: $(SVGINDICES)
svglink: $(SVGLINKS)

png: $(PNGS)
cursor: $(CURSORS)
index: $(INDICES)
link: $(LINKS)

clean: clean_hotspot clean_svg clean_png clean_themes clean_deb clean_arch clean_ocs

clean_hotspot:
	rm -rf svgconf
clean_svg:
	rm -rf svg
clean_png:
	rm -rf svgpng
clean_themes:
	rm -rf retrosmart-*

# ---------------------------------------------------------------------------
# Instalación
# ---------------------------------------------------------------------------
PREFIX  := /usr/local
DESTDIR :=

DOCS = ChangeLog AUTHORS

INSTALL_DIR := $(DESTDIR)$(PREFIX)
INSTALLED_CURSORS := $(addprefix $(INSTALL_DIR)/share/icons/,$(CURSORS) $(INDICES) $(LINKS))
INSTALLED_LINKS    := $(addprefix $(INSTALL_DIR)/share/icons/,$(LINKS))

install: $(INSTALLED_CURSORS) $(DOCS)
	install -dm 755 $(INSTALL_DIR)/share/doc/$(PKGNAME)
	install -dm 755 $(INSTALL_DIR)/share/licenses/$(PKGNAME)
	install -Dm 644 $(DOCS) $(INSTALL_DIR)/share/doc/$(PKGNAME)
	install -Dm 644 README.md $(INSTALL_DIR)/share/doc/$(PKGNAME)/README
	install -Dm 644 ChangeLog $(INSTALL_DIR)/share/doc/$(PKGNAME)/
	install -Dm 644 AUTHORS $(INSTALL_DIR)/share/doc/$(PKGNAME)/
	install -Dm 644 LICENSE $(INSTALL_DIR)/share/licenses/$(PKGNAME)/COPYING

# Los alias de cursor son symlinks: se instalan preservando el enlace
# (cp -P), no copiando el contenido resuelto como haría "install".
# Regla de patrón estática: solo se aplica a los archivos listados en
# $(INSTALLED_LINKS), y tiene prioridad sobre la regla genérica de abajo
# para esos archivos concretos.
$(INSTALLED_LINKS): $(INSTALL_DIR)/share/icons/%: %
	mkdir -p $(dir $@)
	cp -P $< $@

# Resto de archivos instalados (cursores reales generados por xcursorgen,
# index.theme, cursor.theme): "install -D" ya crea los directorios
# intermedios que hagan falta, así que no hace falta "install -d" antes.
$(INSTALL_DIR)/share/icons/%: %
	install -Dm 644 $< $@

uninstall:
	rm -Rf $(INSTALLED_CURSORS)
	rm -rf $(INSTALL_DIR)/share/doc/$(PKGNAME)
	rm -rf $(INSTALL_DIR)/share/licenses/$(PKGNAME)
	rm -rf $(INSTALL_DIR)/share/icons/retrosmart-bitmap-xcursor-*
	rm -rf $(INSTALL_DIR)/share/icons/retrosmart-vector-xcursor-*


# ---------------------------------------------------------------------------
# Empaquetado DEB (Debian / Ubuntu)
# ---------------------------------------------------------------------------
pkg_deb: $(DEBPKG)

$(DEBPKG): svgtheme
	rm -rf $(DEB_DIR)
	# Crear estructura basica del paquete Debian
	mkdir -p $(DEB_DIR)/DEBIAN
	chmod 755 $(DEB_DIR)/DEBIAN
	# Instalar los archivos dentro del directorio temporal del paquete
	$(MAKE) install PREFIX=/usr DESTDIR=$(DEB_DIR)
	# Generar archivo de control debian
	echo "Package: $(PKGNAME)" > $(DEB_DIR)/DEBIAN/control
	echo "Version: $(VERSION)" >> $(DEB_DIR)/DEBIAN/control
	echo "Section: x11" >> $(DEB_DIR)/DEBIAN/control
	echo "Priority: optional" >> $(DEB_DIR)/DEBIAN/control
	echo "Architecture: $(DEBARCH)" >> $(DEB_DIR)/DEBIAN/control
	echo "Maintainer: $(NAME) <$(MAIL)>" >> $(DEB_DIR)/DEBIAN/control
	echo "Description: $(DESCRIPTION)" >> $(DEB_DIR)/DEBIAN/control
	# Construir el paquete .deb
	dpkg-deb --build --root-owner-group $(DEB_DIR) $(DEBPKG)
	rm -rf $(DEB_DIR)

clean_deb:
	rm -rf $(DEB_DIR) $(DEBPKG)

# ---------------------------------------------------------------------------
# Empaquetado Arch Linux (pacman)
# ---------------------------------------------------------------------------
pkg_arch: $(ARCHPKG)

$(ARCHPKG): svgtheme
	rm -rf $(ARCH_DIR)
	mkdir -p $(ARCH_DIR)
	# Generar el PKGBUILD dinámicamente
	echo "pkgname=$(PKGNAME)" > $(ARCH_DIR)/PKGBUILD
	echo "pkgver=$(VERSION)" >> $(ARCH_DIR)/PKGBUILD
	echo "pkgrel=1" >> $(ARCH_DIR)/PKGBUILD
	echo "pkgdesc=\"$(DESCRIPTION)\"" >> $(ARCH_DIR)/PKGBUILD
	echo "arch=('any')" >> $(ARCH_DIR)/PKGBUILD
	echo "url=\"$(URL)\"" >> $(ARCH_DIR)/PKGBUILD
	echo "license=('$(LICENSE)')" >> $(ARCH_DIR)/PKGBUILD
	echo "options=('!strip' '!zipman')" >> $(ARCH_DIR)/PKGBUILD
	echo "package() {" >> $(ARCH_DIR)/PKGBUILD
	echo "  cd \"$(CURDIR)\"" >> $(ARCH_DIR)/PKGBUILD
	echo "  $(MAKE) install PREFIX=/usr DESTDIR=\"\$$pkgdir\"" >> $(ARCH_DIR)/PKGBUILD
	echo "}" >> $(ARCH_DIR)/PKGBUILD
	# Construir el paquete usando makepkg (requiere pkgext='pkg.tar.zst')
	cd $(ARCH_DIR) && PKGEXT=$(ARCHPKGEXT) makepkg -f -e --nodeps
	mv $(ARCH_DIR)/$(ARCHPKG) .
	rm -rf $(ARCH_DIR)

clean_arch:
	rm -rf $(ARCH_DIR) $(ARCHPKG)

# ---------------------------------------------------------------------------
# Empaquetado OCS
# ---------------------------------------------------------------------------
SVGOCSPKGS := $(PKGNAME)-$(VERSION)-vector.tar.xz
OCSPKGS    := $(SVGOCSPKGS)

pkg_ocs: $(OCSPKGS)

# Depende de "svgtheme" (no solo de estar presente en disco): sin esto,
# "make -j16 all" podía empaquetar el tarball en paralelo con la propia
# generación del tema, metiendo en el .tar.xz una copia a medio construir.
# Al depender de un target phony, este paso se repite siempre que se pida
# "pkg_ocs"/"all", lo cual es lo deseable para un paso de empaquetado.
$(SVGOCSPKGS): svgtheme
	tar -c -I 'xz -T$(THREADS)' -f $@ retrosmart-vector-xcursor-*

clean_ocs:
	rm -rf $(OCSPKGS)

.PHONY: all svghotspot svgtheme svg svgpng svgcursor svgindex svglink \
        png cursor index link \
        clean clean_hotspot clean_svg clean_png clean_themes clean_ocs \
        install uninstall showin pkg_deb pkg_arch pkg_ocs


PREVIEW := alias context-menu default help progress3 size_bdiag col-resize all-scroll
PREVIEWCOMMON := pointer openhand text wait01 pirate zoom-in cell crosshair dnd-no-drop

PREVIEWBLACK := $(addprefix svgpng/retrosmart-vector-xcursor-black-color-shadow/96-, $(PREVIEW) $(PREVIEWCOMMON))
PREVIEWWHITE := $(addprefix svgpng/retrosmart-vector-xcursor-white-color-shadow/96-, $(PREVIEW))

PREVIEW := $(addsuffix .png,$(PREVIEWBLACK) $(PREVIEWWHITE))

preview.png: 
	montage $(PREVIEW) -tile 5x5 -geometry 96x96+10+10 $@

