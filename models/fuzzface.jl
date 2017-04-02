# 2017 Ben Holmes
# MIT license

using ACME

# Model of the Jim Dunlop Fuzz Face guitar pedal;

function fuzzface(::Type{Circuit}; fuzz=nothing, vol=nothing)

    # components
    rIn = resistor( 1e3 )
    r1  = resistor( 11e3 )  # r1 + rC2
    r2  = resistor( 680 )
    r3  = resistor( 62e3 )
    r4  = resistor( 36e3 )
    rB1 = resistor( 2 )
    rE1 = resistor( 0.487 )
    rC1 = resistor( 0.34 )
    rB2 = resistor( 2 )
    rE2 = resistor( 0.487 )

    if vol == nothing
        volPot = potentiometer( 10e3 )
    else
        volPot = potentiometer( 10e3, vol)
    end

    if fuzz == nothing
        fuzzPot = potentiometer( 1e3 )
    else
        fuzzPot = potentiometer( 1e3, fuzz )
    end

    c1  = capacitor( 22e-6 )
    c2  = capacitor( 0.1e-6 )
    c3  = capacitor( 2.2e-6 )
    c5  = capacitor( 6.8e-9 )
    cCB1 = capacitor( 100e-12 )
    cCB2 = capacitor( 100e-12 )

    q1  = bjt( :pnp, is=1.976e-5, βf=103.5, βr=10 )
    q2  = bjt( :pnp, is=1.976e-5, βf=103.5, βr=10 )

    Vin  = voltagesource()    # input
    Vout = voltageprobe()     # output
    Vcc  = voltagesource( 9 ) # supply

    # Connect circuit
    circ = Circuit()

    # Vcc and Vin input stages
    connect!( circ, Vcc[:+], rE1[1], fuzzPot[1] )        # n1
    connect!( circ, Vin[:+], rIn[1] )                    # n2
    connect!( circ, c5[1], rIn[2], c3[1])                # n3

    connect!( circ, Vin[:-], Vcc[:-], c5[2], :gnd )      # gnd

    # BJT1
    connect!( circ, c3[2], rB1[1], r3[1] )               # n4
    connect!( circ, rB1[2], cCB1[1], q1[:base] )         # n5
    connect!( circ, rE1[2], q1[:emitter] )               # n6
    connect!( circ, cCB1[2], rC1[1], q1[:collector] )    # n7
    connect!( circ, rC1[2], r4[1], rB2[1] )              # n8

    connect!( circ, r4[2], :gnd )                        # gnd

    # Fuzz and BJT2
    connect!( circ, rB2[2], cCB2[1], q2[:base] )         # n9
    connect!( circ, fuzzPot[2], c1[1] )                  # n10
    connect!( circ, fuzzPot[3], rE2[1], r3[2] )          # n11
    connect!( circ, rE2[2], q2[:emitter] )               # n12
    connect!( circ, cCB2[2], r1[1], q2[:collector] )     # n13

    connect!( circ, c1[2], :gnd )                        # gnd

    # Output
    connect!( circ, r1[2], r2[1], c2[1] )                # n14
    connect!( circ, volPot[3], c2[2] )                   # n15
    connect!( circ, volPot[2], Vout[:+] )                # n16

    connect!( circ, r2[2], volPot[1], Vout[:-], :gnd )   # gnd

    return circ
end

fuzzface{T<:DiscreteModel}(::Type{T}=DiscreteModel; fuzz=0.5, vol=0.99, fs=44100) =
    T(fuzzface(Circuit, fuzz=fuzz, vol=vol), 1//fs)
