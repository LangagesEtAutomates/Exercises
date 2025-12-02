# Concurrent Multithreaded Programming - TD

This repository contains modular and reusable teaching materials used to build the exercise sheets
for the Concurrent Multithreaded Programming course at Nantes University. 
See the [main organization](https://github.com/ProgrammationMultiThread/) for more information on the course and additional resources.

---

## Structure

```
├── LICENSE.md            # License CC-BY-SA 4.0  
├── Makefile              # Automatic compilation  
├── README.md             # This file  
├── build/                # Temporary files used during compilation  
├── latex-libs/           # Dependency from [latex-libs](https://github.com/MatthieuPerrin/latex-libs)  
├── docs/                 # Compiled PDFs (final course sheets)  
├── src/                  # LaTeX source files  
│   ├── TD/               # Main document files for the exercise sheets  
│   ├── TP/               # Main document files for the practical section sheets  
│   ├── corrections/      # Dependency from [Corrections](https://github.com/ProgrammationMultiThread/Corrections)  (private repository, non required)  
│   ├── exercises/        # Individual exercises organized by topics (one file per exercise)
│   ├── img/              # Images used in the exercises  
│   └── sty/              # Style files  
```

---

## Compilation

To build all exercise sheets (the TD booklet and all TP subjects):

```bash
make
```

This command produces:

```
docs/td.pdf
docs/tp-concurrence.pdf
docs/tp-webgrep.pdf
docs/tp-mandelbrot.pdf
docs/tp-transactions.pdf
```

You can also compile a single document:

```bash
make td          # Builds the TD booklet (docs/td.pdf)
make webgrep     # Builds docs/tp-webgrep.pdf
make tp-webgrep  # Same as above
make tp          # Builds all TP sheets
```

If you have access to the private  
[ProgrammationMultiThread/Corrections](https://github.com/ProgrammationMultiThread/Corrections) repository:

```bash
make correction  # Builds docs/td-correction.pdf
make both        # Builds both docs/td.pdf and docs/td-correction.pdf
```

The correction version includes hidden solutions and requires an SSH key with access to the private repo.

---

## Dependencies

The Makefile automatically manages required dependencies:

- [latex-libs](https://github.com/MatthieuPerrin/latex-libs) – cloned on first build (requires Internet only once).
- [Corrections](https://github.com/ProgrammationMultiThread/Corrections) – optional private repo (for correction versions).

To update all dependencies:

```bash
make update
```

---

## License

All **LaTeX sources, exercise sheets, and related teaching materials** in this repository
are distributed under the **Creative Commons Attribution–ShareAlike 4.0 International** (CC BY-SA 4.0) license.  

- The full legal text of this license is available in [`LICENSE.txt`](LICENSE.txt).  
- Detailed attributions, image credits, and cross-repository licensing notes
  are provided in the [organization-wide license file](https://github.com/ProgrammationMultiThread/.github/blob/main/LICENSE.md).

This license applies only to **original educational materials** created for the course.
Code snippets and external resources may have their own specific licenses
as indicated in the global attribution file.

### Suggested attribution

> *"Exercises and materials from the course **Programmation Concurrente en Multi-Threads** —  
> © 2025 Matthieu Perrin, licensed under CC BY-SA 4.0."*

---

## Contributing

Each exercise is in a separate file, making it easy to reuse or improve specific parts. You can:
- Propose new exercises
- Improve existing content or visuals
- Translate to other languages

Use pull requests to suggest changes.
For significant changes, please open an issue first to discuss your ideas.

