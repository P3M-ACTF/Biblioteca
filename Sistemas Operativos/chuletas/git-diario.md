# Chuleta: Git diario

Operaciones habituales: clonar, estado, diff, commit, ramas, pull/push y stash.

---

## 1. Clonar y configurar (mínimo)

```bash
git clone https://github.com/org/repo.git
cd repo
git config user.name "Tu Nombre"    # si no está global
git config user.email "tu@correo"
```

---

## 2. Estado y diferencias

```bash
git status
git status -sb
git diff                  # working tree vs índice
git diff --staged         # índice vs último commit
git log --oneline -n 15
git log --oneline --graph --decorate -n 20
```

| Estado | Significado |
|--------|-------------|
| untracked | fichero nuevo no añadido |
| modified | cambiado respecto al commit |
| staged | en el índice, listo para commit |

---

## 3. Añadir y commit

```bash
git add ruta/fichero
git add -p                    # trozos interactivos
git commit -m "Mensaje claro"
git commit --amend            # solo si aún no has pusheado / con cuidado
```

Mensaje: qué y por qué, en presente o infinitivo; una línea suele bastar.

---

## 4. Ramas

```bash
git branch
git branch nombre
git switch nombre             # o: git checkout nombre
git switch -c nombre          # crear y cambiar
git merge otra-rama
git branch -d nombre          # borrar si ya fusionada
```

---

## 5. Remoto: pull y push

```bash
git remote -v
git fetch origin
git pull origin main          # fetch + merge (o rebase si lo tienes configurado)
git push -u origin nombre-rama
git push
```

Antes de push: `status` + `diff` + tests si aplica. No reescribas historia pública sin acuerdo.

---

## 6. Stash

```bash
git stash push -m "wip"
git stash list
git stash pop
git stash apply stash@{0}
git stash drop
```

Útil para cambiar de rama con cambios locales no listos para commit.

---

## 7. Deshacer con cuidado

| Situación | Comando orientativo |
|-----------|---------------------|
| Quitar del índice, conservar fichero | `git restore --staged ruta` |
| Descartar cambios en working tree | `git restore ruta` (destructivo) |
| Nuevo commit que revierte otro | `git revert HASH` |
| Mover punta de rama local no pusheada | `git reset` (conoce `--soft`/`--mixed`/`--hard`) |

---

## 8. Checklist diario

| Paso | Comando |
|------|---------|
| ¿Qué hay? | `git status -sb` |
| Revisar | `git diff` / `git diff --staged` |
| Guardar | `add` + `commit` |
| Actualizar | `pull` / `fetch` |
| Publicar | `push` |
| Aparcar | `stash` |

---

*Biblioteca — Sistemas Operativos · Git diario*
