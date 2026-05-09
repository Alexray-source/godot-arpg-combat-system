extends Trigger
class_name GPUParticleTrigger

@export var target_particle : GPUParticles3D

func execute(_params):
	target_particle.restart()
