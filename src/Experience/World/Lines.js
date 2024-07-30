import * as THREE from 'three'
import Model from './Abstracts/Model.js'
import Experience from '../Experience.js'
import Debug from '../Utils/Debug.js'
import State from "../State.js";
import Materials from "../Materials/Materials.js";


export default class Lines extends Model {
    experience = Experience.getInstance()
    debug = Debug.getInstance()
    state = State.getInstance()
    materials = Materials.getInstance()
    scene = experience.scene
    time = experience.time
    camera = experience.camera.instance
    renderer = experience.renderer.instance
    resources = experience.resources
    container = new THREE.Group();


    constructor() {
        super()

        this.setModel()
        this.setDebug()
    }



    setModel() {
        this.lines = this.resources.items.linesModel.scene
        this.lines.scale.setScalar( 500 )
        this.lines.position.y = -100

        this.container.add( this.lines )
        this.scene.add( this.container )
    }

    resize() {

    }

    setDebug() {
        if ( !this.debug.active ) return

        //this.debug.createDebugTexture( this.resources.items.displacementTexture )
    }

    update( deltaTime ) {
        //this.lines.scale.setScalar( this.time.elapsed * 10 )
    }

}
