import streamlit as st
import matplotlib.pyplot as plt

from qiskit import QuantumCircuit, transpile
from qiskit.quantum_info import Statevector
from qiskit.visualization import plot_bloch_multivector
from qiskit_aer import AerSimulator


# ============================================================
# PAGE CONFIGURATION
# ============================================================

st.set_page_config(
    page_title="Quantum Circuit Designer & Simulator",
    page_icon="⚛️",
    layout="wide"
)


# ============================================================
# TITLE
# ============================================================

st.title("⚛️ Quantum Circuit Designer and Simulator")

st.markdown("""
### Interactive Qiskit Application

Design, visualize and simulate fundamental quantum circuits.
The application supports single-qubit gates, multi-qubit gates,
measurements, statevector analysis and circuit statistics.
""")


# ============================================================
# CIRCUIT CREATION FUNCTIONS
# ============================================================

def create_circuit(name, theta=1.5708):

    if name == "Identity":
        qc = QuantumCircuit(1)
        qc.id(0)

    elif name == "Pauli-X":
        qc = QuantumCircuit(1)
        qc.x(0)

    elif name == "Pauli-Y":
        qc = QuantumCircuit(1)
        qc.y(0)

    elif name == "Pauli-Z":
        qc = QuantumCircuit(1)
        qc.z(0)

    elif name == "Hadamard":
        qc = QuantumCircuit(1)
        qc.h(0)

    elif name == "Phase-S":
        qc = QuantumCircuit(1)
        qc.s(0)

    elif name == "Phase-T":
        qc = QuantumCircuit(1)
        qc.t(0)

    elif name == "Rx":
        qc = QuantumCircuit(1)
        qc.rx(theta, 0)

    elif name == "Ry":
        qc = QuantumCircuit(1)
        qc.ry(theta, 0)

    elif name == "Rz":
        qc = QuantumCircuit(1)
        qc.rz(theta, 0)

    elif name == "Measurement":
        qc = QuantumCircuit(1, 1)
        qc.h(0)
        qc.measure(0, 0)

    elif name == "CNOT":
        qc = QuantumCircuit(2)
        qc.cx(0, 1)

    elif name == "CZ":
        qc = QuantumCircuit(2)
        qc.cz(0, 1)

    elif name == "SWAP":
        qc = QuantumCircuit(2)
        qc.x(0)
        qc.swap(0, 1)

    elif name == "Toffoli":
        qc = QuantumCircuit(3)
        qc.x(0)
        qc.x(1)
        qc.ccx(0, 1, 2)

    elif name == "Bell State":
        qc = QuantumCircuit(2)
        qc.h(0)
        qc.cx(0, 1)

    elif name == "GHZ State":
        qc = QuantumCircuit(3)
        qc.h(0)
        qc.cx(0, 1)
        qc.cx(0, 2)

    return qc


# ============================================================
# STATEVECTOR SIMULATION
# ============================================================

def get_statevector(qc):

    # Remove measurements before calculating statevector
    circuit_for_state = qc.remove_final_measurements(
        inplace=False
    )

    return Statevector.from_instruction(
        circuit_for_state
    )


# ============================================================
# MEASUREMENT SIMULATION
# ============================================================

def get_counts(qc, shots):

    measured = qc.copy()

    # Add measurements if the circuit has none
    if measured.num_clbits == 0:
        measured.measure_all()

    simulator = AerSimulator()

    compiled = transpile(
        measured,
        simulator
    )

    result = simulator.run(
        compiled,
        shots=shots,
        seed_simulator=42
    ).result()

    return result.get_counts()


# ============================================================
# SIDEBAR
# ============================================================

st.sidebar.header("⚙️ Circuit Controls")

circuit_names = [
    "Identity",
    "Pauli-X",
    "Pauli-Y",
    "Pauli-Z",
    "Hadamard",
    "Phase-S",
    "Phase-T",
    "Rx",
    "Ry",
    "Rz",
    "Measurement",
    "CNOT",
    "CZ",
    "SWAP",
    "Toffoli",
    "Bell State",
    "GHZ State"
]

selected = st.sidebar.selectbox(
    "Select Circuit",
    circuit_names
)


# ============================================================
# ROTATION ANGLE
# ============================================================

theta = 3.141592653589793 / 2

if selected in ["Rx", "Ry", "Rz"]:

    theta = st.sidebar.slider(
        "Rotation Angle θ",
        min_value=0.0,
        max_value=6.2832,
        value=1.5708,
        step=0.1
    )

    st.sidebar.write(
        f"θ = {theta:.2f} radians"
    )


# ============================================================
# SHOTS
# ============================================================

shots = st.sidebar.slider(
    "Number of Shots",
    min_value=100,
    max_value=5000,
    value=1024,
    step=100
)


# ============================================================
# CREATE SELECTED CIRCUIT
# ============================================================

qc = create_circuit(
    selected,
    theta
)


# ============================================================
# CIRCUIT DIAGRAM
# ============================================================

st.header("1️⃣ Circuit Diagram")

st.code(
    qc.draw("text"),
    language="text"
)


# ============================================================
# STATEVECTOR
# ============================================================

state = get_statevector(qc)

st.header("2️⃣ Quantum State")

st.write("Statevector:")

st.code(
    str(state),
    language="text"
)


# ============================================================
# PROBABILITIES
# ============================================================

st.header("3️⃣ State Probabilities")

probabilities = state.probabilities_dict()

probability_table = {
    str(k): round(float(v), 6)
    for k, v in probabilities.items()
}

st.json(probability_table)


# ============================================================
# MEASUREMENTS
# ============================================================

counts = get_counts(
    qc,
    shots
)

st.header("4️⃣ Measurement Results")

st.write(
    f"Number of shots: **{shots}**"
)

st.write(counts)


# ============================================================
# HISTOGRAM
# ============================================================

st.header("5️⃣ Measurement Histogram")

fig, ax = plt.subplots()

states = list(counts.keys())
values = list(counts.values())

ax.bar(
    states,
    values
)

ax.set_xlabel("Measured State")
ax.set_ylabel("Number of Measurements")
ax.set_title(
    f"{selected} - Measurement Results"
)

st.pyplot(fig)

plt.close(fig)


# ============================================================
# QUANTUM STATE VISUALIZATION
# ============================================================

st.header("6️⃣ Quantum State Visualization")

if state.num_qubits == 1:

    try:

        fig = plot_bloch_multivector(
            state
        )

        st.pyplot(fig)

        plt.close(fig)

    except Exception as error:

        st.warning(
            f"Bloch sphere visualization unavailable: {error}"
        )

else:

    st.info(
        "The selected circuit contains multiple qubits. "
        "The statevector and measurement distribution are "
        "shown above."
    )


# ============================================================
# CIRCUIT INFORMATION
# ============================================================

st.header("7️⃣ Circuit Information")

col1, col2, col3 = st.columns(3)

with col1:

    st.metric(
        "Qubits",
        qc.num_qubits
    )

with col2:

    st.metric(
        "Circuit Depth",
        qc.depth()
    )

with col3:

    st.metric(
        "Total Gates",
        sum(qc.count_ops().values())
    )


st.subheader("Gate Count")

st.write(
    qc.count_ops()
)


# ============================================================
# TRANSPILATION ANALYSIS
# ============================================================

st.header("8️⃣ Transpilation Analysis")

simulator = AerSimulator()

transpiled = transpile(
    qc,
    simulator,
    optimization_level=3
)

col1, col2 = st.columns(2)

with col1:

    st.subheader("Original Circuit")

    st.code(
        qc.draw("text"),
        language="text"
    )

    st.write(
        "Original depth:",
        qc.depth()
    )

    st.write(
        "Original gates:",
        qc.count_ops()
    )


with col2:

    st.subheader("Transpiled Circuit")

    st.code(
        transpiled.draw("text"),
        language="text"
    )

    st.write(
        "Transpiled depth:",
        transpiled.depth()
    )

    st.write(
        "Transpiled gates:",
        transpiled.count_ops()
    )


# ============================================================
# THEORETICAL RESULT
# ============================================================

st.header("9️⃣ Theoretical Result")

theory = {

    "Identity":
        "The qubit remains in |0⟩.",

    "Pauli-X":
        "Pauli-X flips |0⟩ to |1⟩.",

    "Pauli-Y":
        "Pauli-Y transforms |0⟩ to i|1⟩.",

    "Pauli-Z":
        "Pauli-Z applies a phase flip to |1⟩.",

    "Hadamard":
        "Hadamard creates the superposition (|0⟩ + |1⟩)/√2.",

    "Phase-S":
        "Phase-S applies a π/2 phase shift.",

    "Phase-T":
        "Phase-T applies a π/4 phase shift.",

    "Rx":
        "Rx rotates the state around the X-axis.",

    "Ry":
        "Ry rotates the state around the Y-axis.",

    "Rz":
        "Rz rotates the state around the Z-axis.",

    "Measurement":
        "Measurement converts a quantum state into a classical result.",

    "CNOT":
        "CNOT flips the target when the control qubit is |1⟩.",

    "CZ":
        "CZ applies a phase flip when both qubits are |1⟩.",

    "SWAP":
        "SWAP exchanges the states of two qubits.",

    "Toffoli":
        "Toffoli flips the target when both control qubits are |1⟩.",

    "Bell State":
        "Bell state creates entanglement: (|00⟩ + |11⟩)/√2.",

    "GHZ State":
        "GHZ state creates three-qubit entanglement: (|000⟩ + |111⟩)/√2."
}

st.info(
    theory[selected]
)


# ============================================================
# FOOTER
# ============================================================

st.markdown("---")

st.caption(
    "Quantum Circuit Designer and Simulator | "
    "Python + Qiskit + Qiskit Aer + Streamlit"
)
