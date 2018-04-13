# Simulations on Supersingular Isogeny Graphs

This repository includes various simulations written in Sage for supersingular isogeny graphs to estimate the distributions of `j(E_A)`, `j(E_B)` and `j(E_AB)` of SIDH/SIKE schemes. The code is partially based on [Erik Thormarker's similar work](https://github.com/eriktho/thesis-sage-code).

In order to run the simulation scripts, first of all you need to build and link the scipts using the make command:

> make

Then, you can run the script  

> sage simulation_secret.sage

which runs the simulations to estimate the distributions of `j(E_A)` and `j(E_B)`, or the script

> sage simulation_shared.sage

which runs the simulation to estiamte the distribution of `j(E_AB)`.

The file `plot.R` reads the ouput of the simulations, plots the results and exports the plots as `.pdf` files.

## License

This project is licensed under the MIT License; see [`LICENSE`](LICENSE) for details.

## Contributing

This project has adopted the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/),
with the following additional clauses:

* We respect the rights to privacy and anonymity for contributors and people in
  the community. If someone wishes to contribute under a pseudonym different to
  their primary identity, that wish is to be respected by all contributors. 


If you have questions or comments, please feel free to email the author. For feature requests, suggestions, and bug reports, please [open an issue on this Github repository](https://github.com/etairi/isogeny-graphs/issues) (or, send an email to the author). Patches are also welcomed as [pull requests on this GitHub repository](https://github.com/etairi/isogeny-graphs/pulls), as well as by
email.
